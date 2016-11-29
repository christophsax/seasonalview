
var shinyIDCallback = new Shiny.InputBinding();

// An input binding must implement these methods
$.extend(shinyIDCallback, {


  // This returns a jQuery object with the DOM element
  find: function(scope) {
    // return $(scope).find('.saxophon');
    return $(scope).find('.shiny-id-callback');
  },

  // return the ID of the DOM element
  getId: function(el) {
    return el.id;
  },

  // Given the DOM element for the input, return the value
  getValue: function(el) {
    var values = new Array();
    $.each($(el).find(".shiny-id-el.active"), function() {
      values.push($(this).attr('id'));
      if ($(this).hasClass("shiny-force")) {
        values.push(Math.random());  // to cause reevaluateion at each click

      }
    });
    return values;
  },

  // Given the DOM element for the input, set the value
  setValue: function(el, value) {
    el.value = value;
  },

  // Set up the event listeners so that interactions with the
  // input will result in data being sent to server.
  // callback is a function that queues data to be sent to
  // the server.
  subscribe: function(el, callback) {
    $(el).on('click.shinyIDCallback', function(event) {
      callback(true);
      // When called with false, it will NOT use the rate policy,
      // so changes will be sent immediately
    });
  },

  // Remove the event listeners
  unsubscribe: function(el) {
    $(el).off('.shinyIDCallback');
  },
});

Shiny.inputBindings.register(shinyIDCallback, 'shiny.shinyIDCallback');

