document.querySelector('#year').textContent = new Date().getFullYear();

const translations = {
  fr: {
    title: 'Bible Open — La Bible, ouverte à tous', description: 'Bible Open rassemble des outils simples pour découvrir, comprendre et vivre la Bible.', brandLabel: 'Bible Open, accueil', bibleAlt: 'Bible réelle ouverte', languageLabel: 'Choisir la langue', navApps: 'Nos applications', heroEyebrow: 'Une bibliothèque qui grandit avec vous', heroTitle: 'La Bible,<br /><em>ouverte à tous.</em>', heroIntro: 'Explorez les Écritures, approfondissez votre foi et testez vos connaissances grâce à des outils accessibles, pensés pour chaque jour.', discover: 'Découvrir les applications', verse: 'Ta parole est une lampe à mes pieds, et une lumière sur mon sentier.', verseRef: 'Psaume 119:105', ecosystem: "L'écosystème Bible Open", appsTitle: 'Un même élan,<br />deux façons d’avancer.', appsIntro: 'Choisissez votre chemin : apprendre en jouant ou prendre le temps d’étudier.', available: 'Disponible', unavailableOnline: 'Bientôt en ligne', quizKicker: 'Apprendre & jouer', quizDescription: 'Des questions pour découvrir la Bible autrement, progresser et partager un moment stimulant.', openQuiz: 'Accéder au Quizz', external: 'Ouvrir dans un navigateur externe', studyKicker: 'Lire & approfondir', studyDescription: 'Un espace complet pour lire, annoter et étudier les textes tout en nourrissant une réflexion personnelle.', openStudy: 'Accéder à Study Bible', footerTagline: 'Des outils numériques au service de la Parole.',
  },
  en: {
    title: 'Bible Open — The Bible, open to everyone', description: 'Bible Open brings together simple tools to discover, understand and live the Bible.', brandLabel: 'Bible Open, home', bibleAlt: 'Real open Bible', languageLabel: 'Choose language', navApps: 'Our applications', heroEyebrow: 'A library that grows with you', heroTitle: 'The Bible,<br /><em>open to everyone.</em>', heroIntro: 'Explore Scripture, deepen your faith and test your knowledge with accessible tools designed for everyday use.', discover: 'Discover the applications', verse: 'Your word is a lamp to my feet and a light to my path.', verseRef: 'Psalm 119:105', ecosystem: 'The Bible Open ecosystem', appsTitle: 'One shared purpose,<br />two ways forward.', appsIntro: 'Choose your path: learn through play or take time for deeper study.', available: 'Available', unavailableOnline: 'Coming online', quizKicker: 'Learn & play', quizDescription: 'Questions to discover the Bible differently, make progress and share a stimulating moment.', openQuiz: 'Open Bible Quiz', external: 'Open in an external browser', studyKicker: 'Read & explore', studyDescription: 'A complete space to read, annotate and study texts while nurturing personal reflection.', openStudy: 'Open Study Bible', footerTagline: 'Digital tools serving the Word.',
  },
  mg: {
    title: 'Bible Open — Baiboly misokatra ho an’ny rehetra', description: 'Bible Open dia manangona fitaovana tsotra hahitana, hahatakarana ary hiainana ny Baiboly.', brandLabel: 'Bible Open, fandraisana', bibleAlt: 'Baiboly tena izy misokatra', languageLabel: 'Safidio ny fiteny', navApps: 'Ny rindranasanay', heroEyebrow: 'Tranomboky mitombo miaraka aminao', heroTitle: 'Ny Baiboly,<br /><em>misokatra ho an’ny rehetra.</em>', heroIntro: 'Diniho ny Soratra Masina, halalino ny finoanao ary zahao ny fahalalanao amin’ny fitaovana mora ampiasaina isan’andro.', discover: 'Jereo ireo rindranasa', verse: 'Fanilon’ny tongotro sy fanazavana ny lalako ny teninao.', verseRef: 'Salamo 119:105', ecosystem: 'Ny tontolon’ny Bible Open', appsTitle: 'Tanjona iray,<br />lalana roa handrosoana.', appsIntro: 'Safidio ny lalanao: mianara amin’ny lalao na manokàna fotoana handalinana.', available: 'Azo ampiasaina', unavailableOnline: 'Ho avy an-tserasera', quizKicker: 'Mianatra & milalao', quizDescription: 'Fanontaniana hahitana ny Baiboly amin’ny fomba hafa, handrosoana ary hizarana fotoana mahaliana.', openQuiz: 'Sokafy ny Quizz', external: 'Sokafy amin’ny navigateur ivelany', studyKicker: 'Mamaky & mandalina', studyDescription: 'Toerana feno hamakiana, hanamarihana ary handalinana ny Soratra Masina.', openStudy: 'Sokafy ny Study Bible', footerTagline: 'Fitaovana nomerika ho fanompoana ny Tenin’Andriamanitra.',
  },
};

const supportedLanguages = Object.keys(translations);
const detectedLanguage = (navigator.languages?.[0] || navigator.language || 'fr').toLowerCase().split('-')[0];
const savedLanguage = localStorage.getItem('bible-open-language');
const activeLanguage = supportedLanguages.includes(savedLanguage) ? savedLanguage : (supportedLanguages.includes(detectedLanguage) ? detectedLanguage : 'fr');
const copy = translations[activeLanguage];

document.documentElement.lang = activeLanguage;
document.title = copy.title;
document.querySelector('meta[name="description"]').content = copy.description;
document.querySelectorAll('[data-i18n]').forEach((element) => { element.textContent = copy[element.dataset.i18n]; });
document.querySelectorAll('[data-i18n-html]').forEach((element) => { element.innerHTML = copy[element.dataset.i18nHtml]; });
document.querySelectorAll('[data-i18n-aria]').forEach((element) => { element.setAttribute('aria-label', copy[element.dataset.i18nAria]); });
document.querySelectorAll('[data-i18n-alt]').forEach((element) => { element.alt = copy[element.dataset.i18nAlt]; });

const languageSelect = document.querySelector('#language-select');
languageSelect.value = activeLanguage;
languageSelect.addEventListener('change', (event) => {
  localStorage.setItem('bible-open-language', event.target.value);
  window.location.reload();
});

const localHosts = new Set(['localhost', '127.0.0.1', '::1']);
const isLocalEnvironment = localHosts.has(window.location.hostname);

function disableApplication(appId) {
  document.querySelectorAll(`[data-app-link="${appId}"]`).forEach((link) => {
    link.removeAttribute('href');
    link.setAttribute('aria-disabled', 'true');
    link.setAttribute('tabindex', '-1');
  });

  const status = document.querySelector(`[data-app-status="${appId}"]`);
  if (status) status.textContent = copy.unavailableOnline;
}

async function configureApplicationLinks() {
  try {
    const response = await fetch('/config/applications.json', { cache: 'no-store' });
    if (!response.ok) throw new Error(`Application registry unavailable (${response.status})`);

    const registry = await response.json();
    ['quiz', 'study'].forEach((appId) => {
      const app = registry.applications?.[appId];
      const targetUrl = isLocalEnvironment ? app?.localUrl : app?.productionUrl;

      if (!targetUrl) {
        disableApplication(appId);
        return;
      }

      document.querySelectorAll(`[data-app-link="${appId}"]`).forEach((link) => {
        link.href = targetUrl;
      });
    });
  } catch (error) {
    console.error('Bible Open application registry error:', error);
    ['quiz', 'study'].forEach(disableApplication);
  }
}

configureApplicationLinks();

const cards = document.querySelectorAll('.app-card');
const reveal = new IntersectionObserver(
  (entries) => entries.forEach((entry) => entry.isIntersecting && entry.target.classList.add('is-visible')),
  { threshold: 0.18 },
);

cards.forEach((card) => reveal.observe(card));

const animatedTextBlocks = document.querySelectorAll([
  '.hero-copy h1',
  '.hero-copy .intro',
  '.verse-card > p',
  '.section-heading h2',
  '.section-heading > p',
  '.card-kicker',
  '.card-content h3',
  '.card-content > p:not(.card-kicker)',
].join(','));

function wrapWords(element) {
  const walker = document.createTreeWalker(element, NodeFilter.SHOW_TEXT);
  const textNodes = [];

  while (walker.nextNode()) textNodes.push(walker.currentNode);

  let wordIndex = 0;
  textNodes.forEach((node) => {
    if (!node.textContent?.trim()) return;

    const fragment = document.createDocumentFragment();
    node.textContent.split(/(\s+)/).forEach((part) => {
      if (!part) return;
      if (/^\s+$/.test(part)) {
        fragment.append(part);
        return;
      }

      const word = document.createElement('span');
      word.className = 'word-reveal';
      word.style.setProperty('--word-delay', `${Math.min(wordIndex * 55, 880)}ms`);
      word.textContent = part;
      fragment.append(word);
      wordIndex += 1;
    });

    node.replaceWith(fragment);
  });
}

animatedTextBlocks.forEach(wrapWords);

const textReveal = new IntersectionObserver(
  (entries) => entries.forEach((entry) => {
    if (entry.isIntersecting) {
      entry.target.classList.add('text-is-visible');
      textReveal.unobserve(entry.target);
    }
  }),
  { threshold: 0.28, rootMargin: '0px 0px -5% 0px' },
);

animatedTextBlocks.forEach((block) => textReveal.observe(block));
