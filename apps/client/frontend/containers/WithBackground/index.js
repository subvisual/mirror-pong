import React, { Component, Fragment } from 'react';
import _ from 'lodash';

import Centered from '../../components/Centered';
import Channel from '../../lib/channel';
import Sponsors from './sponsors';

import './index.css';

export default function(Child) {
  return class WithBackground extends Component {
    state = {
      index: Sponsors.length,
      score: {
        left: 0,
        right: 0,
      },
      loading: true,
    };

    constructor(props) {
      super(props);

      this.channel = new Channel('game:metadata');

      this.joinChannel();
    }

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

      this.leaveChannel();
    }

    joinChannel = async () => {
      try {
        const response = await this.channel.join();

        console.log('Joined successfully', response); // eslint-disable-line no-console

        const left = _.get(response, 'game.score_left');
        const right = _.get(response, 'game.score_right');

        this.setState({ score: { left, right }, loading: false });
        this.subscribeToGoals();
      } catch (error) {
        console.log('Unable to join', error); // eslint-disable-line no-console
      }
    };

    subscribeToGoals = () => {
      this.channel.on('player_scored', data => {
        this.setState({
          score: { left: data.score_left, right: data.score_right },
        });
      });
    };

    leaveChannel = async () => {
      try {
        const response = await this.channel.leave();

        console.log('Left successfully', response); // eslint-disable-line no-console
      } catch (error) {
        console.log('Error while leaving the channel', error); // eslint-disable-line no-console
      }
    };

    renderSponsorLogo() {
      const { index } = this.state;

      const LogoComponent = Sponsors[index];

      return <LogoComponent />;
    }

    render() {
      const {
        index,
        score: { left, right },
        loading,
      } = this.state;

      if (loading) return null;

      const renderLogo =
        index === Sponsors.length ? 'Mirror Conf' : this.renderSponsorLogo();

      return (
        <Fragment>
          <div styleName="root">
            <div styleName="score">{`${left} - ${right}`}</div>
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
