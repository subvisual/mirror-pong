import React, { Component } from 'react';
import PropTypes from 'prop-types';

import './index.css';

export default class Controller extends Component {
  static propTypes = {
    channel: PropTypes.shape({
      push: PropTypes.func.isRequired,
    }).isRequired,
  };

  handleUp = () => {
    const { channel } = this.props;

    this.mouseInterval = setInterval(
      () => channel.push('player:move', { direction: 'up' }),
      15
    );
  };

  handleDown = () => {
    const { channel } = this.props;

    this.mouseInterval = setInterval(
      () => channel.push('player:move', { direction: 'down' }),
      15
    );
  };

  handleMouseUp = () => {
    clearInterval(this.mouseInterval);
  };

  render() {
    return (
      <div>
        <div
          styleName="arrow"
          onMouseDown={this.handleUp}
          onMouseUp={this.handleMouseUp}
          role="presentation"
        >
          ↑
        </div>
        <div
          styleName="arrow"
          onMouseDown={this.handleDown}
          onMouseUp={this.handleMouseUp}
          role="presentation"
        >
          ↓
        </div>
      </div>
    );
  }
}
