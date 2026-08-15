document.querySelector('#year').textContent = new Date().getFullYear();

const cards = document.querySelectorAll('.app-card');
const reveal = new IntersectionObserver(
  (entries) => entries.forEach((entry) => entry.isIntersecting && entry.target.classList.add('is-visible')),
  { threshold: 0.18 },
);

cards.forEach((card) => reveal.observe(card));
