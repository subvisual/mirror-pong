import React from 'react';
import ReactDOM from 'react-dom';
import WebFont from 'webfontloader';
import App from './components/App';

import './reset.css';
import './normalize.css';
import './settings.css';

const renderReactApp = () => {
  ReactDOM.render(<App />, document.getElementById('root'));
};

WebFont.load({
  google: {
    families: ['VT323'],
  },
  active: renderReactApp,
});
