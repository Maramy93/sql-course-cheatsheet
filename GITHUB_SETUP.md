# Create your GitHub repository

Suggested name: **`sql-course-cheatsheet`**.

Suggested description: **Original PostgreSQL tutorials, visual SQL explanations, runnable examples, and interview revision notes.**

The supplied ZIP already contains all repository files. Extract it first. The folder containing README.md is the repository root. Do not upload the ZIP itself as your repository content.

## Option A · GitHub website (no Terminal needed)

1. Sign in to [GitHub](https://github.com/).
2. Click **+ → New repository** (or open [github.com/new](https://github.com/new)).
3. Set the owner to your account, **Maramy93**, and name it `sql-course-cheatsheet`.
4. Choose Public if you want a shareable study/portfolio resource; choose Private if you prefer personal access.
5. Leave “Add a README”, licence, and .gitignore unchecked: these files are already in this folder. Click **Create repository**.
6. On the empty repository page, use **uploading an existing file**. If you initialized the repo instead, use **Add file → Upload files**.
7. Open the extracted `sql-course-cheatsheet` folder in Finder. Drag its contents (README.md, docs, sql, assets, exercises, python, tests, etc.) into the upload area. Upload the contents rather than the containing folder to keep README.md at the root. Hidden `.gitignore` may need to be added separately using Add file → Create new file if Finder doesn't expose it.
8. Use commit message `Add original PostgreSQL study guide` and commit changes.
9. Open README.md and follow a chapter link. Verify illustrations appear and folders are present. GitHub renders Markdown, SVG images, and Mermaid code blocks; raw .sql files remain readable source files.
10. Optionally add topics in the About panel: `sql`, `postgresql`, `cheatsheet`, `data-analysis`, `interview-preparation`.

Expected URL, if that name is available: `https://github.com/Maramy93/sql-course-cheatsheet`.

## Option B · Git and Terminal

These instructions use the extracted folder. Replace the directory if you moved it elsewhere.

```bash
cd ~/Downloads/sql-course-cheatsheet

git --version
git init -b main
git add .
git commit -m "Add original PostgreSQL study guide"
```

If macOS offers command-line tools when checking git, complete that installation. If Git asks for your identity, set your desired name and your verified GitHub email or GitHub-provided no-reply email:

```bash
git config user.name "YOUR NAME"
git config user.email "YOUR VERIFIED OR NO-REPLY EMAIL"
```

Then repeat the commit. These settings apply to this repository when run without `--global`.

Create an **empty** GitHub repository as in steps 1–5 above. Then:

```bash
git remote add origin https://github.com/Maramy93/sql-course-cheatsheet.git
git push -u origin main
```

Authenticate using an approved GitHub authentication method, such as GitHub CLI (`gh auth login`), a credential manager, a personal access token for HTTPS, or SSH. GitHub account passwords do not authenticate Git HTTPS pushes. Never embed a token in the remote URL or put one in a file committed to the repo.

If you already added a remote, inspect `git remote -v` before changing it. If the remote contains its own initial commit, clone that repository and copy these files into the clone instead of forcing a push.

## Optional GitHub CLI shortcut

If GitHub CLI is already installed, initialize/commit locally as above, then:

```bash
gh auth login
gh repo create Maramy93/sql-course-cheatsheet --public --source=. --remote=origin --push
```

Use `--private` instead of `--public` if desired. Do this **instead of** manually creating an empty remote and adding origin. If the name is taken, choose another name and update the URL.

## Update your notes later

```bash
git status
git add docs CHEATSHEET.md my-notes
git commit -m "Add review notes and new SQL practice"
git push
```

Run the `git add` command only for paths that exist and that you want to commit. A simpler `git add .` stages all non-ignored changes; review `git status` before committing.

## Licence and course attribution

An MIT licence is included for the original content and code in this package. Attribution to the course identifies the learning context; it does not authorize redistributing that course's PDF, slide screenshots, lectures, branding, or third-party materials. Keep those out of the public repo. The supplied third-party attachments were not added to this package.

References: [GitHub: adding local code](https://docs.github.com/en/migrations/importing-source-code/using-the-command-line-to-import-source-code/adding-locally-hosted-code-to-github), [GitHub CLI repo creation](https://cli.github.com/manual/gh_repo_create).
