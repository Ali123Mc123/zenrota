/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./index.html",
  ],
  safelist: [
    'hover:text-orange-500'

  ],
  theme: {
    extend: {
      colors:{
        "dark-purple": "#081A51",
        "light-white": "rgba(255,255,255,0.18)",
        "custom-1" : "#1f2937",
        "custom-2" : "#111827",
        "custom-3" : "#0b0f19",
        "custom-4" : "#aeb6c3",
        "custom-5" : "#E08A7B",
        "nav-color": "#111827",
        "xp-color-dark" : "#0e131f",
        "xp-color-light" : "#131a2b"
      }
    },
  },
  plugins: [],
}