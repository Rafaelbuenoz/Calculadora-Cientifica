(() => {
  function reportHeight() {
    if (window.parent !== window) window.parent.postMessage({type:'noxbo-calculator-height',height:document.body.scrollHeight},window.location.origin);
  }
  if (typeof ResizeObserver !== 'undefined') new ResizeObserver(reportHeight).observe(document.body);
  window.addEventListener('load',reportHeight);
  const script=document.getElementById('dart-code');
  script?.addEventListener('error',()=>{const message=document.getElementById('loading');if(message)message.textContent='A calculadora não carregou. Recarregue a página para tentar novamente.';});
})();
