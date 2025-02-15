(function(){
var self=this||{};try{self.WeakRef=WeakRef,self.FinalizationGroup=FinalizationGroup}catch(e){!function(e,t){var i=new e;function n(e){i.set(this,e)}t(n.prototype,{deref:{value:function(){return i.get(this)}}});var a=new e;function r(e){a.set(this,[])}t(r.prototype,{register:{value:function(e,t){var i=a.get(this);i.indexOf(t)<0&&i.push(t)}},unregister:{value:function(e,t){var i=a.get(this),n=i.indexOf(t);return-1<n&&i.splice(n,1),-1<n}},cleanupSome:{value:function(e){e(a.get(this))}}}),self.WeakRef=n,self.FinalizationGroup=r}(WeakMap,Object.defineProperties)}
})();

{{flutter_js}}
{{flutter_build_config}}

_flutter.buildConfig.builds[0].mainJsPath = "/main.dart.js?v=MAIN_DART_JS_VERSION";

let _host = window.location.hostname.toLowerCase();
window.isCNHost =
  "true" === window.localStorage.getItem("useProxy") ||
  _host.startsWith("cn.") ||
  -1 != "narumi.cc".indexOf(_host) ||
  -1 != ["localhost"].indexOf(_host);

const userConfig = {
  canvasKitBaseUrl: "/canvaskit/",
  renderer: "canvaskit",
};

if(window.isCNHost){
  userConfig.fontFallbackBaseUrl = "https://fonts.gstatic.font.im/s/";
}

_flutter.loader.load({
  config: userConfig,
});
