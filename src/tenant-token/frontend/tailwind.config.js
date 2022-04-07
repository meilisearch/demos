module.exports = {
  content: ['./src/**/*.{js,jsx,ts,tsx}'],
  theme: {
    extend: {
      colors: {
        primary: '#E41359',
        'custom-gray': {
          1: '#39486E',
          2: '#606C8B',
          3: '#A7AEC0',
          4: '#BBC1CF',
          5: '#CBCFDB',
          6: '#EDEEF7',
          7: '#FAFBFE',
        },
      },
      boxShadow: {
        custom: 'rgb(0 0 0 / 4%) 0px 4px 6px',
      },
    },
  },
  plugins: [],
}