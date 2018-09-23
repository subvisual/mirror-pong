import React, { Component } from 'react';
import PropTypes from 'prop-types';
import ControlArrow from '../ControlArrow';

import './index.css';

export default class Controller extends Component {
  static propTypes = {
    channel: PropTypes.shape({
      push: PropTypes.func.isRequired,
    }).isRequired,
  };

  render() {
    const { channel } = this.props;

    return (
      <div styleName="root">
        <ControlArrow channel={channel} direction="up" />
        <ControlArrow channel={channel} direction="down" />
      </div>
    );
  }
}
