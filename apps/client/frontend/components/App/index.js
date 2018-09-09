import React, { Component } from 'react';

import Board from '../Board';

import './index.css';

export default class App extends Component {
  render() {
    return (
      <div>
        <Board width={window.innerWidth} height={window.innerHeight} />
      </div>
    );
  }
}