import React, { Component } from 'react';
import PropTypes from 'prop-types';
import { Circle } from 'react-konva';

const colorGallery = '#eaeaea';

export default class Ball extends Component {
  static propTypes = {
    radius: PropTypes.number.isRequired,
    x: PropTypes.number.isRequired,
    y: PropTypes.number.isRequired,
    fill: PropTypes.string,
  };

  static defaultProps = {
    fill: colorGallery,
  };

  render() {
    const { radius, x, y, fill } = this.props;

    return (
      <Circle
        ref={ref => {
          this.ballRef = ref;
        }}
        x={x}
        radius={radius}
        y={y}
        fill={fill}
      />
    );
  }
}
