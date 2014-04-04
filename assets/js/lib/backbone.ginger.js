/**
 * Ginger BackboneJS
 * Backbone.View initialization plugin
 * Version : 0.2
 * Author: Mickey Spektor
 * www.facebook.com/mickey.spektor
 *
 * Date: 21.04.13
 */

/**
 * Ginger options
 */
Backbone.Ginger = {
    options: {
        // Title for console output
        title: '[BackboneJS Ginger]: ',

        // Template variable name.
        // Can be a:
        // 1. String (Variable) - link to compiled Handlebars template function
        // 2. String (Template) - will be compiled with Handlebars.compile() to function
        // Note: String(template) has less priority than Sting(Variable).
        // String(template) used if templateLinkParentObject.templateVariable not found.
        templateVariable: 'template',

        // templateLinkVariable parent object
        templateParentObject: window,

        // Custom node variable for jQuery selector or Handlebars compiled template
        nodeVariable: 'node',
        // Collection variable, which contains all collections defined by collectionHandler
        collectionVariable: 'collection',
        // User init function, fired after Backbone.View.initialize
        initFunction: 'init',

        // model handler hash (modelHandler : { all : function(){} } ) - fired on all model events
        modelHandler: 'modelHandler',

        // model handler hash (collectionHandler : { collection1 : {all : function(){}} } ) - fired on all collection1 events
        collectionHandler: 'collectionHandler'
    },

    error: function(text) {
        throw new Error(Backbone.Ginger.options.title + text);
    }
};

Backbone.View.prototype.initialize = function(options) {
    var afterChangeMustBeFired = false;
    //Setup node ($el)
    if(this[Backbone.Ginger.options.nodeVariable] != undefined || this[Backbone.Ginger.options.templateVariable] != undefined) {

        if(this[Backbone.Ginger.options.templateVariable] == undefined) {
            if(_(this[Backbone.Ginger.options.nodeVariable]).isString()) {
                if(!(this.$el = $(this[Backbone.Ginger.options.nodeVariable])).length) {
                    Backbone.Ginger.error('Element $("' + this[Backbone.Ginger.options.nodeVariable] + '") not found');
                }
            }
        } else {
            var tpl = Backbone.Ginger.options.templateParentObject[this[Backbone.Ginger.options.templateVariable]];
            if(tpl == undefined) {
                this[Backbone.Ginger.options.nodeVariable] = Handlebars.compile(this[Backbone.Ginger.options.templateVariable]);
            } else {
                if(_(tpl).isFunction()) {
                    this[Backbone.Ginger.options.nodeVariable] = tpl;
                } else {
                    this[Backbone.Ginger.options.nodeVariable] = Handlebars.compile(tpl);
                }
            }

        }

        if(_(this[Backbone.Ginger.options.nodeVariable]).isFunction()) {
            if(this.model == undefined) {
                Backbone.Ginger.error('Backbone.View.model is undefined');
            } else {
                this.$el = $(this[Backbone.Ginger.options.nodeVariable](this.model.toJSON()));
                afterChangeMustBeFired = true;
            }
        } else {
            if(!_(this[Backbone.Ginger.options.nodeVariable]).isString()) {
                Backbone.Ginger.error('Backbone.View.node must be a string (jQuery selector) or Handlebars compiled function');
            }
        }
    }
    //Setup collection handler
    if(_(this[Backbone.Ginger.options.collectionHandler]).isObject()) {
        _(this[Backbone.Ginger.options.collectionHandler]).each(function(events, modelName) {

            if(this[Backbone.Ginger.options.collectionVariable][modelName] == undefined) {
                Backbone.Ginger.error('Collection named "' + modelName + '" is undefined. You should define it as "new <Backbone.View>({ '+Backbone.Ginger.options.collectionVariable+': { '+modelName+':  <Backbone.Collection>} })"');
            }

            if(_(events).isObject()) {
                _(events).each(function(handler, event) {
                    if(_(handler).isFunction()) {
                        this.listenTo(this[Backbone.Ginger.options.collectionVariable][modelName], event, handler);
                    } else {
                        Backbone.Ginger.error('"' + modelName + '" collection handler for "' + event + '" must be a function');
                    }
                }, this);
            } else {
                Backbone.Ginger.error('Collection handler "' + Backbone.Ginger.options.collectionHandler + '" must be a hash');
            }
        }, this);
    }

    // Setup model handler
    if(_(this[Backbone.Ginger.options.modelHandler]).isObject()) {
        if(this.model == undefined) {
            Backbone.Ginger.error('ModelHandler has found, but model is undefined');
        }

        if(!_(this[Backbone.Ginger.options.nodeVariable]).isObject() && !_(this[Backbone.Ginger.options.modelHandler].change).isFunction()) {
            Backbone.Ginger.error('ModelHandler has found. You must define "' + this[Backbone.Ginger.options.nodeVariable] + '" variable as compiled Handlebars template');
        }

        if(_(this.model.validate).isFunction()) {
            this.model.validate();
        }

        if(!_(this[Backbone.Ginger.options.modelHandler].change).isFunction()) {
            this.$el = $(this[Backbone.Ginger.options.nodeVariable](this.model.toJSON()));

            this[Backbone.Ginger.options.modelHandler].change = function() {
                this.$el.html($(this[Backbone.Ginger.options.nodeVariable](this.model.toJSON())).html());
                this.model.trigger('afterChange');
                return this;
            }

        }

        if(!_(this[Backbone.Ginger.options.modelHandler].destroy).isFunction()) {
            this[Backbone.Ginger.options.modelHandler].destroy = function() {
                this.remove();
            }
        }

        _(this[Backbone.Ginger.options.modelHandler]).each(function(handler, event) {
            if(_(handler).isFunction()) {
                this.listenTo(this.model, event, handler);
            } else {
                Backbone.Ginger.error('Model handler for "' + event + '" must be a function');
            }
        }, this);

        if(afterChangeMustBeFired) {
            this.model.trigger('afterChange');
        }
    }

    if(_(this[Backbone.Ginger.options.initFunction]).isFunction()) {
        this[Backbone.Ginger.options.initFunction](options);
    }
};