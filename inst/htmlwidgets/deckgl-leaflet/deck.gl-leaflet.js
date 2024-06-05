(function (global, factory) {
  typeof exports === 'object' && typeof module !== 'undefined' ? factory(exports, require('leaflet'), require('@deck.gl/core')) :
  typeof define === 'function' && define.amd ? define(['exports', 'leaflet', '@deck.gl/core'], factory) :
  (global = typeof globalThis !== 'undefined' ? globalThis : global || self, factory(global.DeckGlLeaflet = {}, global.L, global.deck));
}(this, (function (exports, L, core) { 'use strict';

  function _interopNamespace(e) {
    if (e && e.__esModule) return e;
    var n = Object.create(null);
    if (e) {
      Object.keys(e).forEach(function (k) {
        if (k !== 'default') {
          var d = Object.getOwnPropertyDescriptor(e, k);
          Object.defineProperty(n, k, d.get ? d : {
            enumerable: true,
            get: function () {
              return e[k];
            }
          });
        }
      });
    }
    n['default'] = e;
    return Object.freeze(n);
  }

  var L__namespace = /*#__PURE__*/_interopNamespace(L);

  function _classCallCheck(instance, Constructor) {
    if (!(instance instanceof Constructor)) {
      throw new TypeError("Cannot call a class as a function");
    }
  }

  function _defineProperties(target, props) {
    for (var i = 0; i < props.length; i++) {
      var descriptor = props[i];
      descriptor.enumerable = descriptor.enumerable || false;
      descriptor.configurable = true;
      if ("value" in descriptor) descriptor.writable = true;
      Object.defineProperty(target, descriptor.key, descriptor);
    }
  }

  function _createClass(Constructor, protoProps, staticProps) {
    if (protoProps) _defineProperties(Constructor.prototype, protoProps);
    if (staticProps) _defineProperties(Constructor, staticProps);
    return Constructor;
  }

  function _assertThisInitialized(self) {
    if (self === void 0) {
      throw new ReferenceError("this hasn't been initialised - super() hasn't been called");
    }

    return self;
  }

  function _setPrototypeOf(o, p) {
    _setPrototypeOf = Object.setPrototypeOf || function _setPrototypeOf(o, p) {
      o.__proto__ = p;
      return o;
    };

    return _setPrototypeOf(o, p);
  }

  function _inherits(subClass, superClass) {
    if (typeof superClass !== "function" && superClass !== null) {
      throw new TypeError("Super expression must either be null or a function");
    }

    subClass.prototype = Object.create(superClass && superClass.prototype, {
      constructor: {
        value: subClass,
        writable: true,
        configurable: true
      }
    });
    if (superClass) _setPrototypeOf(subClass, superClass);
  }

  function _typeof(obj) {
    "@babel/helpers - typeof";

    if (typeof Symbol === "function" && typeof Symbol.iterator === "symbol") {
      _typeof = function _typeof(obj) {
        return typeof obj;
      };
    } else {
      _typeof = function _typeof(obj) {
        return obj && typeof Symbol === "function" && obj.constructor === Symbol && obj !== Symbol.prototype ? "symbol" : typeof obj;
      };
    }

    return _typeof(obj);
  }

  function _possibleConstructorReturn(self, call) {
    if (call && (_typeof(call) === "object" || typeof call === "function")) {
      return call;
    }

    return _assertThisInitialized(self);
  }

  function _getPrototypeOf(o) {
    _getPrototypeOf = Object.setPrototypeOf ? Object.getPrototypeOf : function _getPrototypeOf(o) {
      return o.__proto__ || Object.getPrototypeOf(o);
    };
    return _getPrototypeOf(o);
  }

  function _defineProperty(obj, key, value) {
    if (key in obj) {
      Object.defineProperty(obj, key, {
        value: value,
        enumerable: true,
        configurable: true,
        writable: true
      });
    } else {
      obj[key] = value;
    }

    return obj;
  }

  function ownKeys(object, enumerableOnly) { var keys = Object.keys(object); if (Object.getOwnPropertySymbols) { var symbols = Object.getOwnPropertySymbols(object); if (enumerableOnly) { symbols = symbols.filter(function (sym) { return Object.getOwnPropertyDescriptor(object, sym).enumerable; }); } keys.push.apply(keys, symbols); } return keys; }

  function _objectSpread(target) { for (var i = 1; i < arguments.length; i++) { var source = arguments[i] != null ? arguments[i] : {}; if (i % 2) { ownKeys(Object(source), true).forEach(function (key) { _defineProperty(target, key, source[key]); }); } else if (Object.getOwnPropertyDescriptors) { Object.defineProperties(target, Object.getOwnPropertyDescriptors(source)); } else { ownKeys(Object(source)).forEach(function (key) { Object.defineProperty(target, key, Object.getOwnPropertyDescriptor(source, key)); }); } } return target; }
  /** @typedef {import('@deck.gl/core/lib/deck').DeckProps} DeckProps */

  /** @typedef {import('@deck.gl/core/lib/deck').ViewStateProps} ViewStateProps */

  /**
   * @param {L.Map} map
   * @returns {ViewStateProps}
   */

  function getViewState(map) {
    return {
      longitude: map.getCenter().lng,
      latitude: map.getCenter().lat,
      zoom: map.getZoom() - 1,
      pitch: 0,
      bearing: 0
    };
  }
  /**
   * @param {L.Map} map
   * @param {HTMLElement} container
   * @param {Deck} deck
   * @param {DeckProps} props
   * @returns {Deck}
   */


  function createDeckInstance(map, container, deck, props, id) {
    console.log(props.layers[0].id);
    //props.layers[0].id = "scatter-" + new Date(Math.ceil(Math.random() * 1e13)).valueOf().toString(36);
    console.log(props.layers[0].id);
    if (!deck) {
      var viewState = getViewState(map);
      deck = new core.Deck(_objectSpread(_objectSpread({}, props), {}, {
        id: "deckgl-layer", //new Date(Math.ceil(Math.random() * 1e13)).valueOf().toString(36);,
        parent: container,
        controller: false,
        style: {
          zIndex: 'auto'
        },
        viewState: viewState
      }));
    }

    return deck;
  }
  /**
   * @param {Deck} deck
   * @param {L.Map} map
   */

  function updateDeckView(deck, map) {
    var viewState = getViewState(map); // console.log(viewState);

    deck.setProps({
      viewState: viewState
    });
    //deck._needsRedraw = true;
    return deck;
  }

  function _createSuper(Derived) { var hasNativeReflectConstruct = _isNativeReflectConstruct(); return function _createSuperInternal() { var Super = _getPrototypeOf(Derived), result; if (hasNativeReflectConstruct) { var NewTarget = _getPrototypeOf(this).constructor; result = Reflect.construct(Super, arguments, NewTarget); } else { result = Super.apply(this, arguments); } return _possibleConstructorReturn(this, result); }; }

  function _isNativeReflectConstruct() { if (typeof Reflect === "undefined" || !Reflect.construct) return false; if (Reflect.construct.sham) return false; if (typeof Proxy === "function") return true; try { Boolean.prototype.valueOf.call(Reflect.construct(Boolean, [], function () {})); return true; } catch (e) { return false; } }
  /** @typedef {import('@deck.gl/core').Deck} Deck */

  /** @typedef {import('@deck.gl/core/lib/deck').DeckProps} DeckProps */

  var LeafletLayer = /*#__PURE__*/function (_L$Layer) {
    _inherits(LeafletLayer, _L$Layer);

    var _super = _createSuper(LeafletLayer);

    /** @type {HTMLElement | undefined} */

    /** @type {Deck | undefined} */

    /** @type {boolean | undefined} */

    /**
     * @param {DeckProps} props
     */
    function LeafletLayer(props) {
      var _this;

      _classCallCheck(this, LeafletLayer);

      _this = _super.call(this);

      _defineProperty(_assertThisInitialized(_this), "_container", undefined);

      _defineProperty(_assertThisInitialized(_this), "_deck", undefined);

      _defineProperty(_assertThisInitialized(_this), "_animate", undefined);

      _this.props = props;
      return _this;
    }
    /**
     * @returns {this}
     */


    _createClass(LeafletLayer, [{
      key: "onAdd",
      value: function onAdd() {
        console.log(this.props.layers[0].id);
        if (this._deck === undefined) {
          this._container = L__namespace.DomUtil.create('div');
          this._container.className = 'leaflet-layer';

          if (this._zoomAnimated) {
            L__namespace.DomUtil.addClass(this._container, 'leaflet-zoom-animated');
          }
          //console.log(id);
          this.getPane().appendChild(this._container);
          this._deck = createDeckInstance(this._map, this._container, this._deck, this.props);

          this._update();
        } else {
          this._container.hidden = false;
          this.getPane().appendChild(this._container);
        }

        return this;
      }
      /**
       * @param {L.Map} _map
       * @returns {this}
       */

    }, {
      key: "onRemove",
      value: function onRemove(_map) {
        //L__namespace.DomUtil.remove(this._container);

        this._container.hidden = true;
        //this._container = undefined;
        //this._deck.finalize();
        //this._deck = undefined;

        return this;
      }
      /**
       * @returns {Object}
       */

    }, {
      key: "getEvents",
      value: function getEvents() {
        var events = {
          viewreset: this._reset,
          movestart: this._onMoveStart,
          moveend: this._onMoveEnd,
          zoomstart: this._onZoomStart,
          zoom: this._onZoom,
          zoomend: this._onZoomEnd
        };

        if (this._zoomAnimated) {
          events.zoomanim = this._onAnimZoom;
        }

        return events;
      }
      /**
       * @param {DeckProps} props
       * @returns {void}
       */

    }, {
      key: "setProps",
      value: function setProps(props) {
        Object.assign(this.props, props);

        if (this._deck) {
          this._deck.setProps(props);
        }
      }
      /**
       * @param {any} params
       * @returns {any}
       */

    }, {
      key: "pickObject",
      value: function pickObject(params) {
        return this._deck && this._deck.pickObject(params);
      }
      /**
       * @param {any} params
       * @returns {any}
       */

    }, {
      key: "pickMultipleObjects",
      value: function pickMultipleObjects(params) {
        return this._deck && this._deck.pickMultipleObjects(params);
      }
      /**
       * @param {any} params
       * @returns {any}
       */

    }, {
      key: "pickObjects",
      value: function pickObjects(params) {
        return this._deck && this._deck.pickObjects(params);
      }
      /**
       * @returns {void}
       */

    }, {
      key: "_update",
      value: function _update() {
        if (this._map._animatingZoom) {
          return;
        }

        var size = this._map.getSize();

        this._container.style.width = "".concat(size.x, "px");
        this._container.style.height = "".concat(size.y, "px"); // invert map position

        var offset = this._map._getMapPanePos().multiplyBy(-1);

        this._deck._needsRedraw = true;

        L__namespace.DomUtil.setPosition(this._container, offset);
        updateDeckView(this._deck, this._map);
      }
      /**
       * @returns {void}
       */

    }, {
      key: "_pauseAnimation",
      value: function _pauseAnimation() {
        if (this._deck.props._animate) {
          this._animate = this._deck.props._animate;

          this._deck.setProps({
            _animate: false
          });
        }
      }
      /**
       * @returns {void}
       */

    }, {
      key: "_unpauseAnimation",
      value: function _unpauseAnimation() {
        if (this._animate) {
          this._deck.setProps({
            _animate: this._animate
          });

          this._animate = undefined;
        }
      }
      /**
       * @returns {void}
       */

    }, {
      key: "_reset",
      value: function _reset() {
        this._updateTransform(this._map.getCenter(), this._map.getZoom());

        this._update();
      }
      /**
       * @returns {void}
       */

    }, {
      key: "_onMoveStart",
      value: function _onMoveStart() {
        this._pauseAnimation();
      }
      /**
       * @returns {void}
       */

    }, {
      key: "_onMoveEnd",
      value: function _onMoveEnd() {
        this._update();

        this._unpauseAnimation();
      }
      /**
       * @returns {void}
       */

    }, {
      key: "_onZoomStart",
      value: function _onZoomStart() {
        this._pauseAnimation();
      }
      /**
       * @param {L.ZoomAnimEvent} event
       * @returns {void}
       */

    }, {
      key: "_onAnimZoom",
      value: function _onAnimZoom(event) {
        this._updateTransform(event.center, event.zoom);
      }
      /**
       * @returns {void}
       */

    }, {
      key: "_onZoom",
      value: function _onZoom() {
        this._updateTransform(this._map.getCenter(), this._map.getZoom());
      }
      /**
       * @returns {void}
       */

    }, {
      key: "_onZoomEnd",
      value: function _onZoomEnd() {
        this._unpauseAnimation();
      }
      /**
       * see https://stackoverflow.com/a/67107000/1823988
       * see L.Renderer._updateTransform https://github.com/Leaflet/Leaflet/blob/master/src/layer/vector/Renderer.js#L90-L105
       * @param {L.LatLng} center
       * @param {number} zoom
       */

    }, {
      key: "_updateTransform",
      value: function _updateTransform(center, zoom) {
        var scale = this._map.getZoomScale(zoom, this._map.getZoom());

        var position = L__namespace.DomUtil.getPosition(this._container);

        var viewHalf = this._map.getSize().multiplyBy(0.5);

        var currentCenterPoint = this._map.project(this._map.getCenter(), zoom);

        var destCenterPoint = this._map.project(center, zoom);

        var centerOffset = destCenterPoint.subtract(currentCenterPoint);
        var topLeftOffset = viewHalf.multiplyBy(-scale).add(position).add(viewHalf).subtract(centerOffset);

        if (L__namespace.Browser.any3d) {
          L__namespace.DomUtil.setTransform(this._container, topLeftOffset, scale);
        } else {
          L__namespace.DomUtil.setPosition(this._container, topLeftOffset);
        }
      }
    }]);

    return LeafletLayer;
  }(L__namespace.Layer);

  exports.LeafletLayer = LeafletLayer;

  Object.defineProperty(exports, '__esModule', { value: true });

})));
//# sourceMappingURL=deck.gl-leaflet.js.map
