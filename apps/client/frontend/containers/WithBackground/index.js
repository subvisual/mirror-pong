import React, { Component, Fragment } from 'react';

import Scoreboard from '../../components/Scoreboard';
import Centered from '../../components/Centered';
import Sponsors from './sponsors';

import './index.css';

export default function(Child) {
  return class WithBackground extends Component {
    state = {
      index: Sponsors.length,
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
      const { index } = this.state;

      const renderLogo =
        index === Sponsors.length ? 'Mirror Conf' : this.renderSponsorLogo();

      return (
        <Fragment>
          <div styleName="root">
            <div styleName="score">
              <Scoreboard />
            </div>
            <Centered>
              <div styleName="logo">{renderLogo}</div>
            </Centered>
          </div>
          <Child {...this.props} />
        </Fragment>
      );
    }
  };
}
