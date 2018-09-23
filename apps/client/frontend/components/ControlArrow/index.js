import React, { Component } from 'react';
import PropTypes from 'prop-types';
import classnames from 'classnames';

import './index.css';

const ARROWS = {
  up: '↑',
  down: '↓',
};

export default class ControlArrow extends Component {
  static propTypes = {
    channel: PropTypes.shape({
      push: PropTypes.func.isRequired,
    }).isRequired,
    direction: PropTypes.oneOf(['up', 'down']).isRequired,
  };

  state = {
    selected: false,
  };

  componentWillUnmount() {
    clearInterval(this.interval);
  }

  handleControlStart = event => {
    const { channel, direction } = this.props;

    this.interval = setInterval(
      () => channel.push('player:move', { direction }),
      10
    );

    this.setState({ selected: true });

    event.preventDefault();
  };

  handleControlEnd = event => {
    clearInterval(this.interval);

    this.setState({ selected: false });

    event.preventDefault();
  };

  render() {
    const { direction } = this.props;
    const { selected } = this.state;
    const styles = classnames('root', { selected });

    return (
      <div
        id={direction}
        styleName={styles}
        onTouchStart={this.handleControlStart}
        onTouchEnd={this.handleControlEnd}
        onMouseDown={this.handleControlStart}
        onMouseUp={this.handleControlEnd}
        onMouseLeave={this.handleControlEnd}
        ref={ref => {
          this.arrowRef = ref;
        }}
        role="presentation"
      >
        {ARROWS[direction]}
      </div>
    );
  }
}
