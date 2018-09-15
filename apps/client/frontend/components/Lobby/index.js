import React, { Component } from 'react';

import { Link } from 'react-router-dom';

import './index.css';

export default class Lobby extends Component {
  render() {
    return (
      <div styleName="root">
        <Link to="/play" styleName="child">
          Join
        </Link>
      </div>
    );
  }
}
