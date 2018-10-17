import React from 'react';
import _ from 'lodash';

import MirrorConf from './assets/mirror.svg';
import Balsamiq from './assets/balsamiq.png';
import Bosch from './assets/bosch.svg';
import Burocratik from './assets/burocratik.svg';
import Danke from './assets/danke.svg';
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
import Tnds from './assets/tnds.svg';
import Utrust from './assets/utrust.svg';
import Wit from './assets/wit.png';
import Xing from './assets/xing.svg';

const logos = [
  MirrorConf,
  Balsamiq,
  Bosch,
  Burocratik,
  Danke,
  Farfetch,
  Fullsix,
  Ginetta,
  Hi,
  Seegno,
  Hostel,
  Mediaweb,
  PixelMatters,
  Prozis,
  PortugueseWomenInTech,
  StartupBraga,
  Tnds,
  Utrust,
  Wit,
  Xing,
];

const preloadImage = url => {
  const image = new Image();

  image.src = url;
};

const toComponent = (png, index) => () => (
  <img id={`logo_${index}`} height="200" width="200" src={png} alt="" />
);

window.onload = () => {
  _.each(logos, logo => preloadImage(logo));
};

export default _.map(logos, (logo, index) => toComponent(logo, index));
