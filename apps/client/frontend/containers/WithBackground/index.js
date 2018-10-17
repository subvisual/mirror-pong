import React, { Component, Fragment } from 'react';

import Scoreboard from '../../components/Scoreboard';
import Centered from '../../components/Centered';
import Sponsors from './sponsors';

import './index.css';

export default function(Child) {
  return class WithBackground extends Component {
    state = {
      index: 0,
    };

    componentDidMount() {
      this.interval = setInterval(() => {
        this.setState(prevState => {
          const newIndex =
            prevState.index === Sponsors.length ? 0 : prevState.index + 1;

          return { index: newIndex };
        });
      }, 5000);
    }

    componentWillUnmount() {
      clearInterval(this.interval);
    }

    renderSponsorLogo() {
      const { index } = this.state;

      const LogoComponent = Sponsors[index];

      return <LogoComponent />;
    }

    render() {
      return (
        <Fragment>
          <div styleName="root">
            <div styleName="score">
              <Scoreboard />
            </div>
            <div styleName="logo">
              <Centered>{this.renderSponsorLogo()}</Centered>
            </div>
          </div>
          <Child {...this.props} />
        </Fragment>
      );
    }
  };
}
