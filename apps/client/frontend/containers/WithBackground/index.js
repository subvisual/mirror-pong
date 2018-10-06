import React, { Component, Fragment } from 'react';

import Centered from '../../components/Centered';
import Seegno from './sponsors/seegno.svg';
import Bosch from './sponsors/bosch.svg';

import './index.css';

const SPONSORS = [Seegno, Bosch];

export default function(Child) {
  return class WithBackground extends Component {
    state = {
      index: SPONSORS.length,
    };

    componentDidMount() {
      this.interval = setInterval(() => {
        this.setState(prevState => {
          const newIndex =
            prevState.index === SPONSORS.length ? 0 : prevState.index + 1;

          return { index: newIndex };
        });
      }, 5000);
    }

    componentWillUnmount() {
      clearInterval(this.interval);
    }

    sponsorLogo() {
      const { index } = this.state;

      const LogoComponent = SPONSORS[index];

      return <LogoComponent />;
    }

    render() {
      const { index } = this.state;

      const renderLogo =
        index === SPONSORS.length ? 'Mirror Conf' : this.sponsorLogo();

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
