import React, { Component } from 'react';
import PropTypes from 'prop-types';

import _ from 'lodash';
import Konva from 'konva';
import { Rect } from 'react-konva';

export default class Paddle extends Component {
  static propTypes = {
    width: PropTypes.number,
    height: PropTypes.number,
    x: PropTypes.oneOfType([
      PropTypes.number.isRequired,
      PropTypes.func.isRequired,
    ]).isRequired,
    y: PropTypes.oneOfType([
      PropTypes.number.isRequired,
      PropTypes.func.isRequired,
    ]).isRequired,
    fill: PropTypes.oneOfType([PropTypes.string, PropTypes.func]),
  };

  static defaultProps = {
    width: 20,
    height: 200,
    fill: Konva.Util.getRandomColor,
  };

  constructor(props) {
    super(props);

    this.fill = this.evalFill();
  }

  evalCoordinate(coord) {
    const { width, height } = this.props;

    if (_.isFunction(coord)) {
      return coord({ width, height });
    }

    return coord;
  }

  evalFill() {
    const { fill } = this.props;

    if (_.isFunction(fill)) {
      return fill();
    }

    return fill;
  }

  render() {
    const { width, height, x, y } = this.props;

    return (
      <Rect
        x={this.evalCoordinate(x)}
        y={this.evalCoordinate(y) - height / 2}
        width={width}
        height={height}
        fill={this.fill}
      />
    );
  }
}
