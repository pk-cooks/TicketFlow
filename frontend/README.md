# TicketFlow — Frontend

React + Vite + Tailwind CSS frontend for the TicketFlow ticket booking platform.

## Scripts

```bash
npm install     # install dependencies
npm run dev     # start dev server (http://localhost:5173)
npm run build   # production build into dist/
npm run preview # preview the production build
npm run lint    # run oxlint
```

## Structure

```
frontend/
├── public/          # static assets served at /
├── src/
│   ├── App.jsx      # root component
│   ├── main.jsx     # React entry point
│   └── index.css    # Tailwind import + global styles
├── index.html
└── vite.config.js   # Vite + React + Tailwind plugins
```

Backend (Spring Boot) lives in `../backend/` per the tech stack doc.
