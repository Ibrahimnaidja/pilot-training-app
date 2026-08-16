# Math quiz — Flutter + .NET

A multi-user addition/subtraction/multiplication practice app with a
5-second timer per problem. Users create accounts, write equations for
other people to solve, and build a streak by answering correctly. Backend
is a .NET 8 minimal API with PostgreSQL (via EF Core) and JWT auth;
frontend is Flutter.

## Project layout

```
backend/MathQuiz.Api/     .NET 8 minimal API
  Models/                 User, Problem, Attempt, UserStats, LogicAttempt, LogicStats entities
  Data/AppDbContext.cs    EF Core database context
  Endpoints/              Auth, Problems, Attempts, Stats/Leaderboard, Logic
  Services/TokenService.cs   JWT issuing
backend/Dockerfile        Container build for deployment
backend/docker-compose.yml  Local Postgres for development
backend/render.yaml       Render.com deploy config
frontend/math_quiz_app/   Flutter app
  lib/services/api_client.dart          All backend calls + session storage
  lib/services/logic_puzzle_generator.dart   On-device puzzle generation for the Logic Trainer
  lib/data/word_bank.dart               500+ word verbal-reasoning database
  lib/models/logic_puzzle.dart          Logic Trainer puzzle types
  lib/widgets/shape_diagram.dart        CustomPainter shape rendering for diagrammatic puzzles
  lib/screens/            Auth, quiz, create-problem, leaderboard, random-practice, logic-trainer screens
```

## Run locally

**1. Start a local database** (requires Docker):
```bash
cd backend
docker compose up -d
```
This runs Postgres on `localhost:5433` (not the default 5432, to avoid
clashing with a Postgres install you might already have running) with the
credentials already baked into `appsettings.json` for local dev — nothing
else to configure.

**2. Start the backend** (requires the .NET 8 SDK):
```bash
cd backend/MathQuiz.Api
dotnet run
```
Starts the API at `http://localhost:5080`. On first run it creates all the
tables automatically (no separate migration step needed).

**3. Start the frontend** (requires the Flutter SDK):
```bash
cd frontend/math_quiz_app
flutter pub get
flutter run
```

Don't have Docker? Point `ConnectionStrings:Default` in `appsettings.json`
at any Postgres instance you have access to instead (including a free
Neon/Supabase one — see below).

---

## Deploy so it works as an app on your iPhone

True App Store-style native distribution needs a Mac, Xcode, and an Apple
Developer account — not something you can spin up instantly. The fast path
is a **PWA**: host the Flutter web build at a public URL, then on your
iPhone open it in Safari and tap **Share → Add to Home Screen**. You get a
real home-screen icon and a full-screen app experience, no App Store needed.

This repo includes `.github/workflows/deploy.yml`, which rebuilds and
redeploys the web app automatically to GitHub Pages every time you push —
so after the one-time setup below, you never need to run a build command
again, from a phone or a computer.

### One-time setup (can be done entirely from a phone browser)

1. Create a free GitHub account if you don't have one.
2. Open https://github.com/codespaces in Safari, create a blank codespace
   (or one attached to a new empty repo). This gives you a full terminal
   in the browser.
3. In the codespace terminal, upload this zip (drag it into the file
   explorer panel) and run:
   ```bash
   unzip math-quiz.zip -d math-quiz
   cd math-quiz
   git init
   git add .
   git commit -m "Initial commit"
   git branch -M main
   git remote add origin https://github.com/<your-username>/<repo-name>.git
   git push -u origin main
   ```
   (Create the empty repo first at github.com/new if you didn't already.)
4. On github.com → your repo → **Settings → Pages** → set Source to
   "GitHub Actions".
5. Deploy the backend: go to https://render.com → New → Web Service →
   connect the same repo → root directory `backend` → it'll pick up the
   Dockerfile automatically.
   - First, create a free Postgres database at https://neon.tech (takes
     about a minute) and copy its connection string
     (`postgres://user:pass@host/db`).
   - In Render's environment variables for this service, set
     `DATABASE_URL` to that connection string. `JWT_SECRET` is generated
     for you automatically (see `render.yaml`).
   - Copy the resulting service URL (e.g.
     `https://math-quiz-api.onrender.com`).
6. On github.com → your repo → **Settings → Secrets and variables →
   Actions** → New repository secret → name `API_BASE_URL`, value the
   Render URL from step 5.
7. Go to **Actions** tab → run the "Deploy web app" workflow once manually
   (or just push any small change) to trigger the first build.
8. Your app is now live at `https://<your-username>.github.io/<repo-name>/`.
   Open that in Safari on your iPhone → Share → **Add to Home Screen**.

From then on: editing a file directly on github.com (or via the Codespace)
and committing automatically rebuilds and redeploys within a minute or two.

### Doing it from a computer instead

If you'd rather use a computer for the one-time setup:

1. Push this folder to a GitHub repo.
2. Create a free Postgres database at https://neon.tech and copy its
   connection string.
3. Go to https://render.com → New → Web Service → connect the repo.
4. Render will detect `backend/render.yaml` — or manually set:
   - Root directory: `backend`
   - Runtime: Docker
5. Add environment variable `DATABASE_URL` with the Neon connection string.
   `JWT_SECRET` is auto-generated by `render.yaml`.
6. Deploy. You'll get a URL like `https://math-quiz-api.onrender.com`.

(Fly.io and Railway both also work with the same `backend/Dockerfile` if you
prefer either of those instead.)

Note: Render's free tier sleeps after inactivity, so the first request after
a while can take ~30-50 seconds to wake up. Fine for personal use; upgrade
the plan if that's annoying.

### 2. Build the Flutter app for web, pointing at that backend

```bash
cd frontend/math_quiz_app
flutter create .   # only needed once, adds the web/ platform folder
flutter build web --dart-define=API_BASE_URL=https://math-quiz-api.onrender.com
```

This produces static files in `build/web`.

### 3. Deploy the web build (Vercel or Netlify, free)

**Vercel:**
```bash
npm install -g vercel
cd build/web
vercel deploy --prod
```

**Netlify (drag-and-drop, no CLI):**
Go to https://app.netlify.com/drop and drag the `build/web` folder in.

Either gives you a public HTTPS URL, e.g. `https://math-quiz.vercel.app`.

### 4. Add it to your iPhone home screen

1. Open the deployed URL in **Safari** on your iPhone (must be Safari, not
   Chrome, for the install prompt to work).
2. Tap the **Share** icon → **Add to Home Screen**.
3. Name it and tap **Add**.

You now have an app icon that opens full-screen, just like a native app.

## API reference

All endpoints except `/api/auth/*` require an `Authorization: Bearer <token>` header.

- `POST /api/auth/register` `{ username, password }` → `{ token, username, userId }`
- `POST /api/auth/login` `{ username, password }` → `{ token, username, userId }`
- `POST /api/problems` `{ num1, num2, operator: "Add"|"Subtract"|"Multiply" }` → the created problem
- `PUT /api/problems/{id}` (creator only) → updates the problem
- `DELETE /api/problems/{id}` (creator only) → removes the problem
- `GET /api/problems/random` → a random problem someone else created
- `GET /api/problems/mine` → problems you've created
- `POST /api/attempts` `{ problemId, answer, timedOut }` → `{ correct, correctAnswer, currentStreak, bestStreak, totalCorrect, totalAttempts }`
- `GET /api/me/stats` → your current stats
- `GET /api/leaderboard` → top 20 users by best streak
- `POST /api/logic/attempts` `{ category: "NumberSequence"|"Diagrammatic"|"Verbal", correct }` → `{ currentStreak, bestStreak, totalCorrect, totalAttempts }`
- `GET /api/logic/stats` → your current Logic Trainer stats (same shape as above)

## Notes

- The psychology icon on the quiz screen opens the **Logic trainer**: pilot-
  aptitude-style practice (modeled on the Sova assessment used for cadet
  pilot selection — Skyborne/AON) with three categories, picked via a
  dropdown ("Number sequences", "Verbal reasoning", "Diagrammatic
  reasoning", or "Mixed" for a random category each round):
  - **Number sequences** (20s): find the next number in a sequence
    (arithmetic, geometric, alternating-step, increasing-difference, or
    square-based patterns).
  - **Verbal reasoning** (30s): analogies, odd-one-out, and synonym/antonym
    questions generated by randomly recombining a 650+ word database
    (`lib/data/word_bank.dart`, 29 categories, tagged with synonym/antonym/
    part-of/function/cause-effect relationships) — not a fixed question
    bank, so the same exact question essentially never repeats.
  - **Diagrammatic reasoning** (45s): shapes rendered live with
    `CustomPainter` (no image assets). Two rule styles, chosen at random:
    a multi-attribute dependency rule (e.g. odd/even sides linking to
    fill color and a secondary shape count, shown across 2-3 example
    frames) or a sequential transformation (rotate/recolor/count-increment
    across a frame sequence). Every wrong answer option deliberately
    violates exactly one part of the rule, rather than being random noise.
  All three check answers on-device and only report a correct/incorrect
  boolean to the backend (`/api/logic/attempts`), which tracks streak/score
  the same way the main quiz does — this is a separate stat line from the
  addition-practice streak.
- The shuffle icon on the quiz screen opens **Random practice**: an
  addition/subtraction drill with numbers generated on-device (1-99, no
  negative subtraction results). It never calls the backend, so results
  aren't saved and don't touch the leaderboard. Pick a sequence length
  (5/10/20/50 or a custom number) to start; pressing Enter (or tapping
  Check), or letting the 5-second timer run out, silently moves on to the
  next question with no correct/incorrect reveal — the answer field stays
  focused throughout so you can keep typing without reaching for the mouse.
  At the end you get a summary (score, accuracy,
  average response time) and, if you missed any, a list of exactly which
  ones and what you answered.
- Problems are validated on creation/edit: numbers must be 1-99, subtraction
  can't go negative, and multiplication results are capped at 9801 (99×99).
- Only a problem's creator can edit or delete it (enforced server-side).
- Passwords are hashed with ASP.NET Core Identity's `PasswordHasher` (PBKDF2)
  — never stored in plain text.
- Auth tokens are JWTs valid for 30 days, stored on-device via
  SharedPreferences. Fine for a personal project; swap for
  `flutter_secure_storage` if this ever needs to be hardened.
- The schema is created automatically on backend startup
  (`EnsureCreatedAsync`) rather than via EF Core migrations — simplest for
  now. If you need to change the schema later without losing data, switch
  to `dotnet ef migrations add ...` + `dotnet ef database update`.
- CORS is wide open (`AllowAnyOrigin`) for easy setup. Fine for a personal
  project; lock it down to your frontend's exact URL if you make this public.
- `JWT_SECRET` must be set in production (Render generates one for you via
  `render.yaml`). Don't reuse the `dev-only-secret...` value from
  `appsettings.json` anywhere but local development.
