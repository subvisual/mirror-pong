import React, { Component } from 'react';
import PropTypes from 'prop-types';

import Centered from '../Centered';
import Board from '../Board';

export default class BoardCountdown extends Component {
  static propTypes = {
    delay: PropTypes.number,
  };

  static defaultProps = {
    delay: null,
  };

  state = {
    gameStarted: false,
  };

  timeElapsed = 0;

  componentDidMount() {
    const { delay } = this.props;

    if (!delay) {
      this.setState({ gameStarted: true });
    }

    if (delay && !this.interval) {
      this.interval = setInterval(this.countdown, 1000);
    }
  }

  countdown = () => {
    const { delay } = this.props;

    if (this.timeElapsed === delay) {
      clearInterval(this.interval);

      this.interval = null;

      this.setState({ gameStarted: true }); // eslint-disable-line
    } else {
      this.timeElapsed += 1000;

      document.getElementById('timeRemaining').innerHTML = ` ${delay -
        this.timeElapsed}`;
    }
  };

  render() {
    const { delay } = this.props;
    const { gameStarted } = this.state;

    if (!gameStarted) {
      return (
        <Centered>
          <p>
            Game starting in
            <span id="timeRemaining">{` ${delay}`}</span>
          </p>
        </Centered>
      );
    }

    return <Board {...this.props} />;
  }
}
