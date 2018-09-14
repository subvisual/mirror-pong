import React, { Component } from 'react';
import { BrowserRouter as Router, Route } from 'react-router-dom';

import Board from '../Board';
import Controller from '../Controller';
import Lobby from '../Lobby';

import './index.css';

export default class App extends Component {
  render() {
    return (
      <Router>
        <div>
          <Route exact path="/" component={Lobby} />
          <Route exact path="/controller" component={Controller} />
          <Route exact path="/board" component={Board} />
        </div>
      </Router>
    );
  }
}
