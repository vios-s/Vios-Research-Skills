---
name: eidf-job
description: >-
  Use this skill when the user wants to create, edit, or debug a GPU
  Kubernetes Job on the EIDF GPU Service (group eidf105, namespace
  eidf105ns). Triggers include "run this on the cluster", "train on 2 H100s",
  "make me a job yaml", "interactive pod", "serve this model with vllm",
  "my job is Pending", or changing GPUs/memory/image in a
  job.<user>.<project>.yaml, even without saying EIDF or Kubernetes. Fills the
  group templates instead of writing YAML from memory. Do not use for
  non-EIDF clusters or Slurm.
license: MIT
compatibility: Needs kubectl access to the EIDF GPU Service, normally from an eidf105 login VM.
metadata:
  category: "Lab Operations"
  version: "1.0.0"
  author: "VIOS Lab, University of Edinburgh (from vios-s/EIDF_Template)"
---

# EIDF GPU job specs — always from the group templates

People in this group run GPU workloads on the EIDF GPU Service by
`kubectl create`-ing a Kubernetes Job in the shared namespace
`eidf105ns`. The group maintains battle-tested templates; a hand-written
YAML almost always gets something wrong that the templates get right:

- **Ownership labels** (`owner` / `project` / `purpose` on the Job *and*
  its pod template). The shared namespace has ~20 users; these labels are
  how anyone — including cluster tooling like kubmonitor — can tell whose
  workload is whose (`kubectl get pods -l owner=<user>`). A job without
  them is anonymous and gets chased up by the admins. Never drop them.
  `project` is the user's **research project** (`mri_recon`, `fairness`),
  never the `eidf105` group code: the namespace already carries the group,
  so a group-code label would be identical on every workload and tell
  usage reports nothing.
- **Non-root as the actual user**: `runAsUser`/`runAsGroup` matching the
  user's NFS uid/gid, so files written to `/data` are owned correctly.
- **Working pull secret** (`<group>-ecir-read-robot`, so
  `eidf105-ecir-read-robot` here), NFS mount, `/dev/shm` sizing, kueue queue
  label, `PYTHONUNBUFFERED=1` for live logs.

So: **locate the templates, fill the placeholders, keep everything you
don't have a reason to change.**

One more group convention: whatever language the user chats in, write
all generated *files* — yaml, comments inside it, notes — in English.
These files end up in a shared namespace and shared repos, read by
teammates and admins who may not share the user's language. (Replying
to the user in their own language is of course fine.)

## Which namespace?

Everything below says `eidf105ns` — the right default for this group.
The skill generalises though: EIDF naming is regular, group code `eidfXXX`
→ namespace `eidfXXXns` → kueue queue `eidfXXXns-user-queue`. If the user
belongs to a different EIDF group, swap all of those *consistently*
(including the hardcoded `eidf105ns` strings inside the templates —
build.sh does this substitution when run interactively).

The `project` label is **not** part of that chain. It is the user's
research project and cannot be derived from anything — see Step 2.

You cannot list namespaces on this cluster, and the shared kubeconfig
(`/kubernetes/config`) carries no namespace either — but EIDF login VMs
are named after their group, so the code is auto-detectable locally:

```bash
hostname          # eidf105-vios.vms... -> group eidf105
ls -d /home/eidf*  # /home/eidf105 -> same answer
```

Derive the namespace from that, confirm with
`kubectl -n <namespace> get resourcequota` (succeeds only where the
user has access), and ask the user only if those signals disagree or
are absent (e.g. running from a laptop instead of the login VM).

## Step 1 — locate the templates

The Job templates ship with this skill, in the `templates/` folder next to
this SKILL.md:

| Template | Path |
|---|---|
| CUDA batch | `templates/CUDA/job.template.yaml` |
| CUDA interactive | `templates/CUDA/job.interactive.yaml` |
| PyTorch dev pod | `templates/PyTorch_Docker/job.template.yaml` |
| vLLM serving | `templates/vllm/job.template.yaml` (+ `templates/vllm/service.template.yaml`) |
| vLLM interactive | `templates/vllm/job.interactive.yaml` |

Use these unless the user has a clone of
[vios-s/EIDF_Template](https://github.com/vios-s/EIDF_Template) in the
current directory or a parent (look for `build.sh` +
`CUDA/job.template.yaml`) — a clone is the source of truth, so prefer its
copy when both exist. The template paths in Step 3 are relative to either
location.

The bundled copy only covers Job specs. Building a personal image (the
Dockerfiles and the `./build.sh` wizard) needs the full repo:
`git clone https://github.com/vios-s/EIDF_Template`.

## Step 2 — gather the facts (ask only what you can't discover)

| Fact | How to get it |
|---|---|
| username, uid, gid | `id -un`, `id -u`, `id -g` on this login VM — do NOT guess |
| research project | **ask** — see below. Not derivable from anything |
| what kind of job | infer from the request (see Step 3), confirm if ambiguous |
| GPU model + count | user's request, or recommend one (see below) |
| the command / model | user's request |
| secrets needed? | if the workload needs an HF token, W&B key, etc. |

**The research project is the one fact you must ask for.** It fills the
`project` label and is a short name for the strand of work the job belongs
to — `mri_recon`, `fairness`, `diffusion_priors`. Do not derive it from the
namespace, the group code, the image name, or the directory you happen to
be in, and do not invent one: a wrong value is worse than a question,
because usage reports silently group the job under the wrong heading.

Two shortcuts are legitimate. If the user already has a
`job.<them>.<something>.yaml` nearby, or told you earlier in the
conversation what they are working on, propose that value and let them
correct it. Otherwise ask outright — one short question.

**Reuse the group's existing spelling.** Reports group by this value
verbatim, so `mri_recon` and `mri-recon` are two projects. The group
convention is underscores. If a kubmonitor config is around, its
`research_projects:` list is the set of names already in use — prefer one
of those over inventing a variant:

```bash
grep -A10 research_projects ~/.config/kubmonitor/project.yaml 2>/dev/null
```

`kubmonitor validate` (Step 7) warns when a value looks like a misspelling
of a registered one. Treat that warning as a real finding and fix the
label — it means this job's hours would land under a second, near-duplicate
project in every report.

**Scan before you ask.** Most sizing facts are discoverable — prefer a
quick scan over a questionnaire:

```bash
kubectl -n eidf105ns describe resourcequota   # GPUs/CPUs used vs quota RIGHT NOW
kubectl -n eidf105ns get localqueue eidf105ns-user-queue   # queue pressure
```

Fold what you see into the recommendation ("10/12 GPUs are in use, a
4-GPU job will queue — 2 GPUs would start now"). If the user's training
code/configs are at hand, read the obvious signals instead of asking:
the model name/size in their configs, `num_workers` (drives CPU count),
batch size and precision (drive VRAM). When unsure about the current
GPU lineup, check <https://docs.eidf.ac.uk/services/gpuservice/>.

**Right-size instead of defaulting.** If the user didn't specify
resources — or their numbers look badly mismatched to the task — ask
one round of short questions for whatever the scan couldn't answer
(which model / roughly how many parameters, training or inference,
full fine-tune / LoRA / just serving, how many runs in parallel) and
recommend a fit.

Rough VRAM math per model parameter: inference ≈ 2 bytes (bf16) plus ~20%
overhead; LoRA/QLoRA fine-tune ≈ 2–4 bytes; full fine-tune with Adam ≈
16–18 bytes. So a 7B model serves on a 40GB A100, LoRA-tunes on one
80GB card, but full-tunes only sharded across many. Point small
debug/test workloads at MIG slices. Remember the project quota (~12
GPUs shared by the whole group): N parallel runs × G GPUs each all
count against it, so recommend the smallest setup that works and
staggering runs when someone wants a big sweep. If the user hears the
recommendation and still wants their own numbers, use theirs — say the
trade-off in one sentence and move on; it's their job, not yours.

## Step 3 — pick the template by purpose

| User wants to… | Template | `purpose` label |
|---|---|---|
| run a training/batch script to completion | `CUDA/job.template.yaml` | `batch` |
| a shell to exec into (debug, dev, custom kernels) | `CUDA/job.interactive.yaml` | `interactive` |
| an interactive PyTorch/conda dev pod | `PyTorch_Docker/job.template.yaml` | `interactive` |
| serve an LLM with an OpenAI-compatible API | `vllm/job.template.yaml` (+ `vllm/service.template.yaml` if in-cluster access is needed) | `serving` |

The `purpose` label is already correct inside each template — don't
change it, it describes the template's job type.

**Keep interactive pods honest.** A common anti-pattern here is
starting a job whose only purpose is to `kubectl exec` in later — the
GPU stays allocated whether or not anything runs on it, and idle
allocations are plainly visible to everyone on the shared cluster. So
when someone asks for an interactive GPU pod:

- Ask what they would actually run after exec'ing in. If it's a
  concrete command, offer the **batch** template with that command
  instead: it logs to `kubectl logs`, survives SSH disconnects, and
  frees the GPU the moment it finishes.
- Interactive is legitimate for genuinely exploratory work (debugging
  kernels, inspecting data, trying things). Then suggest a **MIG
  slice** unless they need serious VRAM, and add
  `activeDeadlineSeconds: 86400` (24h) to the generated Job so a
  forgotten pod can't squat a GPU for a week — tell the user it's
  there and that they can raise it or resubmit when it expires.

## Step 4 — fill every placeholder, change nothing else

Copy the template to `job.<username_safe>.<project>.yaml` and replace
**all** of:

| Placeholder | Value |
|---|---|
| `<USERNAME>` | login account from `id -un`, **exactly as-is** — this fills the `owner` label and the `/data/users/` path |
| `<USERNAME_SAFE>` | the same account folded to a legal resource name: lowercase, `_` and `.` → `-` (so `ada_lovelace` → `ada-lovelace`). Fills `generateName` and the Service `name` |
| `<USER_ID>` / `<GROUP_ID>` | from `id -u` / `id -g` |
| `<RESEARCH_PROJECT>` | the research project from Step 2 (e.g. `mri_recon`) — ask, never derive from the namespace |
| `<PULL_SECRET>` | the group's ECIR read robot, `<group>-ecir-read-robot` (so `eidf105-ecir-read-robot`) — it must match the namespace's group, or the image pull fails long after the manifest is accepted |
| `<COMMAND>` | the user's command (CUDA batch template; it sits in a YAML block scalar, so quotes inside it are safe) |
| `<MODEL>` | HF model id (vllm template) |
| `<SECRET_ENV_HOOK>` | see Step 6 |

A leftover `<ANYTHING>` makes kubectl reject the file or, worse, ships a
literal `<USERNAME>` label. Grep for `<` before finishing.

**`<USERNAME>` and `<USERNAME_SAFE>` are not interchangeable**, and the two
ways of getting it wrong fail very differently:

- account in a *name* (`generateName: cuda-ada_lovelace-`) → the API server
  refuses to create the Job at all: resource names are RFC 1123 subdomains,
  which allow neither `_` nor uppercase.
- folded form in the *`owner` label* (`owner: ada-lovelace`) → the Job runs
  fine and nothing complains, but it is attributed to an account that does
  not exist, so the person's usage quietly goes missing from reports.

For most accounts the two are identical, which is exactly why this is easy
to miss — it only breaks for the teammates whose account has a `_` or a
capital in it. When they differ, say so in your hand-over notes.

**The image can come from anywhere — don't push people to ECIR.** Both
registries work and the choice is the user's:

- **Docker Hub** (`docker.io/<account>/<image>:<tag>` or just
  `<account>/<image>:<tag>`): public images pull with zero setup — many
  in the group work this way. Leave the template's `imagePullSecrets`
  line in place; it's harmless for Docker Hub pulls. A *private* Docker
  Hub image needs the user's own pull secret
  (`kubectl create secret docker-registry ...`) added to
  `imagePullSecrets`.
- **ECIR** (`registry.eidf.ac.uk/eidf105/<image>:<username>`): the
  group registry the templates default to. Pulls work out of the box
  via the shared robot secret, but the user must have pushed a personal
  image first (`./build.sh` wizard) — otherwise the first deploy ends
  in ImagePullBackOff, so flag it in your hand-over notes. ECIR also
  has storage quota limits; if it's full, Docker Hub is the documented
  fallback (see CONTRIBUTING.md in
  vios-s/EIDF_Template).

If the user already has a working image anywhere, use it as-is — never
make them re-publish to a different registry just for a job file. (The
vllm template uses the shared `:latest` ECIR image, so it works without
any personal build.)

## Step 5 — resources and GPU choice

- Keep `requests` and `limits` **identical** (cluster convention).
- Scale cpu/memory with the GPU count within one node
  (rule of thumb: 8 CPU + 32Gi per GPU; vllm wants more memory).
  Default project quota is ~100 CPU / 1 TiB / **12 GPUs** — requests
  beyond the quota just queue.
- **vLLM serving: set `--tensor-parallel-size` to the `nvidia.com/gpu`
  count.** The template ships with `1`; asking for 2 GPUs without changing
  it leaves one GPU allocated but idle, and a model sized to span both
  cards runs out of memory on one.
- GPU model goes in the `nodeSelector`. The authoritative list lives at
  <https://docs.eidf.ac.uk/services/gpuservice/> (see also
  `training/L1_getting_started/`); as of 2025 the valid
  `nvidia.com/gpu.product` values are:

  | Value | VRAM | Notes |
  |---|---|---|
  | `NVIDIA-H200` | 141GB | only 16 in the whole service — scarce |
  | `NVIDIA-H100-80GB-HBM3` | 80GB | plentiful but high demand |
  | `NVIDIA-A100-SXM4-80GB` | 80GB | good fallback |
  | `NVIDIA-A100-SXM4-40GB` | 40GB | fine for small models |
  | `NVIDIA-A100-SXM4-40GB-MIG-3g.20gb` | 20GB slice | small jobs |
  | `NVIDIA-A100-SXM4-40GB-MIG-1g.5gb` | 5GB slice | debugging/tests |

  A **misspelled value never schedules** — the pod sits Pending forever
  with no loud error, so copy exactly. Omitting the nodeSelector gives a
  *random* GPU type. For debug/interactive pods that mostly compile or
  test code, suggest a MIG slice instead of a whole H100 — it queues
  faster and doesn't burn a scarce GPU.
- `/dev/shm` (`dshm` volume `sizeLimit`) matters for PyTorch dataloaders —
  grow it with memory if the user hits shm errors.
- For batch jobs, offer `ttlSecondsAfterFinished: 1800` on the Job spec
  so finished jobs clean themselves up (the docs recommend it).

## Step 6 — secrets are never written into YAML

If the job needs an HF token / API key, do NOT paste it into the yaml,
a Dockerfile, or the chat. Replace the `# <SECRET_ENV_HOOK>` marker with:

```yaml
          envFrom:
            - secretRef:
                name: <username_safe>-env
```

and tell the user to create the Secret themselves from a local `.env`:

```bash
kubectl -n eidf105ns create secret generic <username_safe>-env --from-env-file=.env
```

If no secrets are needed, just delete the `<SECRET_ENV_HOOK>` line.

## Step 7 — check and hand over

1. If `kubmonitor` is installed, run `kubmonitor validate job.<username_safe>.<project>.yaml`
   — it confirms the ownership labels survived. Fix anything it reports.
2. `kubectl -n eidf105ns create --dry-run=server -f job.<username_safe>.<project>.yaml`
   runs the file through the real admission chain (kueue included)
   without creating anything — a free catch for schema mistakes.
3. Give the user the deploy commands:

```bash
kubectl -n eidf105ns create -f job.<username_safe>.<project>.yaml
kubectl -n eidf105ns get pods -l owner=<username> -w
kubectl -n eidf105ns logs -f <pod-name>        # batch/serving
kubectl -n eidf105ns exec -it <pod-name> -- /bin/bash   # interactive
```

## If the job won't start (Pending / no GPUs of that type)

Users can NOT list cluster nodes (`kubectl get nodes` is Forbidden), so
you cannot check free GPUs directly. What you *can* do:

```bash
kubectl -n eidf105ns get localqueue eidf105ns-user-queue   # queue pressure
kubectl -n eidf105ns get workloads                          # is it admitted by kueue?
kubectl -n eidf105ns describe pod <pod>                     # scheduler events
```

Read the signals: workload not admitted → quota/queue congestion (wait
or shrink the request); admitted but pod `Unschedulable` with "node(s)
didn't match" → the GPU type is misspelled, unavailable to this
namespace, or fully occupied. In that case propose the fallback ladder
**H200 → H100-80GB → A100-80GB → A100-40GB → MIG slice**, and be
explicit about the VRAM step-down (e.g. a model chosen for H200's 141GB
may need a smaller batch, sharding, or quantization on an 80GB card) —
let the user decide rather than silently downgrading.

## Editing an existing job.<user_safe>.<project>.yaml

Apply the requested change (GPUs, image, command, …) and leave the rest
intact — in particular the labels block, securityContext,
imagePullSecrets, and the NFS/dshm volumes. Keep requests = limits in
sync when changing resources, and for vLLM jobs keep
`--tensor-parallel-size` equal to the GPU count. If the file is missing the ownership
labels (an old hand-written one), add them as part of the edit and
mention it to the user.
