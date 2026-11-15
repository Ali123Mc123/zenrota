document.addEventListener("DOMContentLoaded", function () {
  window.countdown = function countdown(endTime, expiredTranslation) {
      let countdownInstance = {
          timeRemaining: "",
          expiredMessage: expiredTranslation,
          remainingMinutes: null,
          endDateTime: new Date(endTime),
          intervalId: null,

          updateCountdown() {
              let now = new Date();
              let distance = this.endDateTime - now;

              if (distance < 1) {
                  this.timeRemaining = this.expiredMessage;
                  this.remainingMinutes = 0;
                  clearInterval(this.intervalId);
                  return;
              }

              let days = Math.floor(distance / (1000 * 60 * 60 * 24));
              let hours = Math.floor(
                  (distance % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60)
              );
              let minutes = Math.floor((distance % (1000 * 60 * 60)) / (1000 * 60));
              let seconds = Math.floor((distance % (1000 * 60)) / 1000);

              this.remainingMinutes = days * 24 * 60 + hours * 60 + minutes;
              if (hours > 0) {
                  this.timeRemaining = `${hours}h ${minutes}m ${seconds}s`;
              } else if (minutes > 0) {
                  this.timeRemaining = `${minutes}m ${seconds}s`;
              } else {
                  this.timeRemaining = `${seconds}s`;
              }
          },

          startCountdown() {
              this.updateCountdown();
              this.intervalId = setInterval(() => {
                  this.updateCountdown();
              }, 1000);
          }
      };

      return countdownInstance;
  };
});