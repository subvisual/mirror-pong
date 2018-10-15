import React from 'react';

import Balsamiq from './assets/balsamiq.png';
import Bosch from './assets/bosch.svg';
import Burocratik from './assets/burocratik.svg';
import Farfetch from './assets/farfetch.svg';
import Fullsix from './assets/fullsix.svg';
import Ginetta from './assets/ginetta.svg';
import Hi from './assets/hi.svg';
import Seegno from './assets/seegno.svg';
import Hostel from './assets/hostelworld.svg';
import Mediaweb from './assets/mediaweb.png';
import PixelMatters from './assets/pixelmatters.svg';
import Prozis from './assets/prozis.svg';
import PortugueseWomenInTech from './assets/pwit.png';
import StartupBraga from './assets/sbs.svg';
import Xing from './assets/xing.svg';

const preloadImage = url => {
  const image = new Image();

  image.src = url;
};

const pngToComponent = png => () => (
  <img height="200" width="200" src={png} alt="" />
);

window.onload = () => {
  preloadImage(Balsamiq);
  preloadImage(Mediaweb);
  preloadImage(PortugueseWomenInTech);
};

export default [
  pngToComponent(Balsamiq),
  Bosch,
  Burocratik,
  Farfetch,
  Fullsix,
  Ginetta,
  Hi,
  Seegno,
  Hostel,
  pngToComponent(Mediaweb),
  PixelMatters,
  Prozis,
  pngToComponent(PortugueseWomenInTech),
  StartupBraga,
  Xing,
];
