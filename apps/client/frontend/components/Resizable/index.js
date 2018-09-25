import React, { Component } from 'react';

export default function(Child) {
  return class Resizable extends Component {
    state = {
      width: window.innerWidth,
      height: window.innerHeight,
    };

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
      return <Child {...this.props} {...this.state} />;
    }
  };
}
