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
import Pwit from './assets/pwit.svg';
import StartupBraga from './assets/sbs.svg';
import Xing from './assets/xing.svg';

const pngToJSX = png => () => (
  <img height="200" width="200" src={png} alt="" />
);

export default [
  pngToJSX(Balsamiq),
  Bosch,
  Burocratik,
  Farfetch,
  Fullsix,
  Ginetta,
  Hi,
  Seegno,
  Hostel,
  pngToJSX(Mediaweb),
  PixelMatters,
  Prozis,
  Pwit,
  StartupBraga,
  Xing,
];
