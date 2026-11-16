const features = [
  {
    title: 'Discover events',
    description: 'Browse concerts, conferences and workshops in one place.',
  },
  {
    title: 'Book in seconds',
    description: 'Pick your seats, pay securely and get instant tickets.',
  },
  {
    title: 'Manage with ease',
    description: 'Organizers publish events, track sales and handle refunds.',
  },
]

function App() {
  return (
    <div className="min-h-screen bg-slate-950 text-slate-200">
      <header className="border-b border-slate-800">
        <nav className="mx-auto flex max-w-6xl items-center justify-between px-6 py-4">
          <span className="text-lg font-semibold tracking-tight text-white">
            Ticket<span className="text-indigo-400">Flow</span>
          </span>
          <div className="flex items-center gap-6 text-sm">
            <a href="#features" className="text-slate-300 hover:text-white">
              Features
            </a>
            <button
              type="button"
              className="rounded-lg bg-indigo-500 px-4 py-2 font-medium text-white hover:bg-indigo-400"
            >
              Sign in
            </button>
          </div>
        </nav>
      </header>

      <main>
        <section className="mx-auto max-w-3xl px-6 py-24 text-center">
          <p className="mb-4 text-sm font-medium uppercase tracking-widest text-indigo-400">
            Ticket booking platform
          </p>
          <h1 className="text-4xl font-bold tracking-tight text-white sm:text-6xl">
            Find your next event,
            <br />
            book it in seconds.
          </h1>
          <p className="mx-auto mt-6 max-w-xl text-lg text-slate-400">
            TicketFlow connects customers with event organizers — from discovery
            and payments to refunds and entry.
          </p>
          <div className="mt-10 flex flex-wrap justify-center gap-4">
            <button
              type="button"
              className="rounded-lg bg-indigo-500 px-6 py-3 font-medium text-white hover:bg-indigo-400"
            >
              Browse events
            </button>
            <button
              type="button"
              className="rounded-lg border border-slate-700 px-6 py-3 font-medium text-slate-200 hover:border-slate-500"
            >
              Become an organizer
            </button>
          </div>
        </section>

        <section id="features" className="mx-auto max-w-6xl px-6 pb-24">
          <div className="grid gap-6 sm:grid-cols-3">
            {features.map((feature) => (
              <article
                key={feature.title}
                className="rounded-xl border border-slate-800 bg-slate-900/50 p-6"
              >
                <h2 className="text-lg font-semibold text-white">
                  {feature.title}
                </h2>
                <p className="mt-2 text-sm text-slate-400">
                  {feature.description}
                </p>
              </article>
            ))}
          </div>
        </section>
      </main>

      <footer className="border-t border-slate-800 py-6 text-center text-sm text-slate-500">
        TicketFlow — built by the greatest inconsistent MFs
      </footer>
    </div>
  )
}

export default App
