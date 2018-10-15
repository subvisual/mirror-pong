import { Socket } from 'phoenix';

export default class Channel {
  constructor(channelname) {
    this.socket = new Socket('/socket');
    this.socket.connect();
    this.channel = this.socket.channel(channelname);
  }

  join = () =>
    new Promise((resolve, reject) => {
      this.channel
        .join()
        .receive('ok', response => resolve(response))
        .receive('error', response => reject(response));
    });

  leave = () => {
    const promise = new Promise((resolve, reject) => {
      this.channel
        .leave()
        .receive('ok', response => resolve(response))
        .receive('error', response => reject(response));
    });

    promise.finally(() => {
      this.socket.disconnect();
    });

    return promise;
  };

  on = (event, callback) => {
    this.channel.on(event, callback);
  };

  push = (event, payload) => {
    this.channel.push(event, payload);
  };
}
