import React, { Component } from 'react';
import { BrowserRouter as Router, Route } from 'react-router-dom';
import { hot } from 'react-hot-loader';
import BoardRoom from '../BoardRoom';
import GameRoom from '../GameRoom';
import Lobby from '../Lobby';

import './index.css';

class App extends Component {
  render() {
    return (
      <Router>
        <div>
          <Route exact path="/" component={Lobby} />
          <Route exact path="/play" component={GameRoom} />
          <Route exact path="/board" component={BoardRoom} />
        </div>
      </Router>
    );
  }
}

export default hot(module)(App);
