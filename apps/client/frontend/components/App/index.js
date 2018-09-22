import React, { Component } from 'react';
import { BrowserRouter as Router, Route } from 'react-router-dom';

import BoardRoom from '../BoardRoom';
import PlayRoom from '../PlayRoom';
import Lobby from '../Lobby';

import './index.css';

export default class App extends Component {
  render() {
    return (
      <Router>
        <div>
          <Route exact path="/" component={Lobby} />
          <Route exact path="/play" component={PlayRoom} />
          <Route exact path="/board" component={BoardRoom} />
        </div>
      </Router>
    );
  }
}
