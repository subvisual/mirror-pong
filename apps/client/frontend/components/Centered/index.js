import React, { Component } from 'react';
import PropTypes from 'prop-types';

import './index.css';

export default class Centered extends Component {
  static propTypes = {
    children: PropTypes.node.isRequired,
    style: PropTypes.shape({}),
  };

  static defaultProps = {
    style: {},
  };

  render() {
    const { style, children } = this.props;

    return (
      <div styleName="root" style={style}>
        <div styleName="center">{children}</div>
      </div>
    );
  }
}
