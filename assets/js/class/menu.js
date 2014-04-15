// Generated by CoffeeScript 1.7.1
(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Application.Model.Lobby = (function(_super) {
    __extends(Lobby, _super);

    function Lobby() {
      return Lobby.__super__.constructor.apply(this, arguments);
    }

    return Lobby;

  })(Backbone.Model);

  Application.View.Lobby = (function(_super) {
    __extends(Lobby, _super);

    function Lobby() {
      return Lobby.__super__.constructor.apply(this, arguments);
    }

    Lobby.prototype.node = '#jsLobby';

    Lobby.prototype.mainMenu = null;

    Lobby.prototype.modelHandler = {
      change: function() {}
    };

    Lobby.prototype.init = function() {
      this.mainMenu = Application.createMenu('Main menu', {
        'Single player': function() {
          return Application.Game.trigger('singlePlayer');
        },
        'Player vs CPU': function() {}
      }, this);
      return this.$el.append(this.mainMenu.view.$el);
    };

    return Lobby;

  })(Backbone.View);

  Application.Collection.Menu = (function(_super) {
    __extends(Menu, _super);

    function Menu() {
      return Menu.__super__.constructor.apply(this, arguments);
    }

    Menu.prototype.model = Application.Model.MenuItem;

    Menu.prototype.setTitle = function(title) {
      this.title = title;
      return this.trigger('title', title);
    };

    Menu.prototype.title = '';

    return Menu;

  })(Backbone.Collection);

  Application.View.Menu = (function(_super) {
    __extends(Menu, _super);

    function Menu() {
      return Menu.__super__.constructor.apply(this, arguments);
    }

    Menu.prototype.template = 'tplMenu';

    Menu.prototype.$title = null;

    Menu.prototype.collectionHandler = {
      Menu: {
        title: function(title) {
          return this.$title.text(title);
        },
        add: function(model) {
          var menuItemView;
          menuItemView = new Application.View.MenuItem({
            model: model
          });
          return this.$('.jsMenuItems').append(menuItemView.$el);
        }
      }
    };

    Menu.prototype.render = function() {
      return this.$el = $(this.node({
        title: this.collection.Menu.title
      }));
    };

    Menu.prototype.init = function() {
      var $title;
      this.render();
      return $title = this.$('.jsMenuTitle');
    };

    return Menu;

  })(Backbone.View);

  Application.Model.MenuItem = (function(_super) {
    __extends(MenuItem, _super);

    function MenuItem() {
      return MenuItem.__super__.constructor.apply(this, arguments);
    }

    MenuItem.prototype.triggerHandler = null;

    MenuItem.prototype.context = MenuItem;

    MenuItem.prototype.defaults = {
      title: 'MenuItem',
      active: false,
      value: null,
      values: null
    };

    MenuItem.prototype.init = function(params) {
      if (params.triggerHandler != null) {
        this.triggerHandler = params.triggerHandler;
      }
      if (params.context != null) {
        return this.context = params.context;
      }
    };

    return MenuItem;

  })(Backbone.Model);

  Application.View.MenuItem = (function(_super) {
    __extends(MenuItem, _super);

    function MenuItem() {
      return MenuItem.__super__.constructor.apply(this, arguments);
    }

    MenuItem.prototype.template = 'tplMenuItem';

    MenuItem.prototype.modelHandler = {};

    MenuItem.prototype.events = {
      'click': function() {
        return this.model.triggerHandler.apply(this.model.context);
      }
    };

    return MenuItem;

  })(Backbone.View);

}).call(this);

//# sourceMappingURL=menu.map
