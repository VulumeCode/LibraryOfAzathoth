module.exports = {
  theme: {
    borderWidth: {
      "small": "0.5rem",
    },
    fontFamily: {
      'display': ['Walzhari, Comic Sans MS'],
      'sans': ['Tahoma, Comic Sans MS'],
    },
    container: {
      center: true
    },
    extend: {
      keyframes: {
        blink: {
          '0%, 100%': {
            opacity: 1
          },
          '50%': {
            opacity: 0
          },
        }
      },
      animation: {
        blink: 'blink 0.25s cubic-bezier(0.4, 0, 0.6, 1) infinite',
      }
    },
  },
  variants: {
    extend: {
      backgroundColor: ['active'],
    }
  },
  plugins: []
};
