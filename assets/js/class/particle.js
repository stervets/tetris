// Generated by CoffeeScript 1.7.1
(function() {
  Application.Particle = (function() {
    Particle.prototype.params = {
      x: 0,
      y: 0,
      distanceX: 200,
      distanceY: 30,
      lifetime: 300,
      particlesMax: 5,
      stackSize: 120
    };

    Particle.prototype.color = ['#FFFFFF', '#98eb2f', '#ffd739', '#70e8a0', '#4baaef', '#f36252', '#af6cbb'];

    Particle.prototype.particleHtml = $('#tplParticle').html();

    Particle.prototype.sparkHtml = $('#tplSpark').html();

    Particle.prototype.$el = null;

    Particle.prototype.play = false;

    Particle.prototype.stepTime = 10;

    Particle.prototype.$particle = [];

    Particle.prototype.pointer = 0;

    Particle.prototype.launch = function(x, y, color, x2) {
      var $p;
      $p = this.$particle[this.pointer];
      $p.css({
        top: y + this.params.y,
        left: x + this.params.x,
        opacity: 1,
        rotate: "" + (rand(-180, 180)) + "deg",
        scale: 2.5,
        color: this.color[color],
        transition: 'none'
      });
      _.delay(function($p, params, x, y, x2) {
        $p.css({
          top: y + rand(0, params.distanceY) + params.y,
          left: (x2 != null ? x2 : x) + params.x,
          scale: 0,
          rotate: "" + (rand(-180, 180)) + "deg",
          color: 'white',
          transition: "all " + params.lifetime + "ms ease"
        });
        return null;
      }, this.stepTime, $p, this.params, x, y, x2);
      if (++this.pointer >= this.$particle.length) {
        return this.pointer = 0;
      }
    };

    function Particle(params) {
      var $spark, i, _i, _ref;
      _(this.params).extend(params);
      this.$el = $(this.particleHtml);
      this.$particle = [];
      for (i = _i = 1, _ref = this.params.stackSize; 1 <= _ref ? _i <= _ref : _i >= _ref; i = 1 <= _ref ? ++_i : --_i) {
        $spark = $(this.sparkHtml).css({
          transitionDuration: "" + this.params.lifetime + "ms"
        });
        this.$particle.push($spark);
        this.$el.append($spark);
      }
    }

    return Particle;

  })();

}).call(this);

//# sourceMappingURL=particle.map
