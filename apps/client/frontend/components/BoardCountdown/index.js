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

  constructor(props) {
    super(props);

    const { delay } = props;

    if (delay) {
      this.iterations = delay / 1000;
    }
  }

  componentWillMount() {
    const { delay } = this.props;

    if (!delay) {
      this.setState({ gameStarted: true });
    } else {
      // leave a margin for transmission and processing deltas
      this.interval = setInterval(this.countdown, 750);
    }
  }

  countdown = () => {
    if (this.iterations > 1) {
      this.iterations -= 1;

      document.getElementById('timeRemaining').innerHTML = ` ${
        this.iterations
      } seconds`;
    } else {
      clearInterval(this.interval);

      this.interval = null;

      this.setState({ gameStarted: true }); // eslint-disable-line
    }
  };

  render() {
    const { gameStarted } = this.state;

    if (!gameStarted) {
      return (
        <Centered>
          <p>
            Game starting in
            <span id="timeRemaining">{` ${this.iterations} seconds`}</span>
          </p>
        </Centered>
      );
    }

    return <Board {...this.props} />;
  }
}
