import React, { Component, Fragment } from 'react';

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

    sponsorLogo() {
      const { index } = this.state;

      const LogoComponent = Sponsors[index];

      return <LogoComponent />;
    }

    render() {
      const { index } = this.state;

      const renderLogo =
        index === Sponsors.length ? 'Mirror Conf' : this.sponsorLogo();

      return (
        <Fragment>
          <div styleName="root">
            <div styleName="logo">
              <Centered>{renderLogo}</Centered>
            </div>
          </div>
          <Child {...this.props} />
        </Fragment>
      );
    }
  };
}
