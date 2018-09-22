import React, { Component } from 'react';

import Board from '../Board';

export default class BoardRoom extends Component {
  state = {
    width: null,
    height: null,
  };

  componentWillMount() {
    this.updateDimensions();
  }

  componentDidMount() {
    window.addEventListener('resize', this.updateDimensions);
  }

  componentWillUnmount() {
    window.removeEventListener('resize', this.updateDimensions);
  }

  updateDimensions = () => {
    this.setState({
      width: window.innerWidth,
      height: window.innerHeight,
    });
  };

  render() {
    return <Board {...this.state} />;
  }
}
