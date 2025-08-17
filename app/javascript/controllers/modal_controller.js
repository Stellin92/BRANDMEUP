import { Controller } from "@hotwired/stimulus"
export default class extends Controller {
  static targets = ["overlay","frame"]
  connect(){
    this._onFrameLoad = (e)=>{
      if(e.target.id==="outfit_modal" && e.target.innerHTML.trim()!==""){ this.open() }
    }
    document.addEventListener("turbo:frame-load", this._onFrameLoad)
    this._onKey = (e)=>{ if(e.key==="Escape") this.close() }
    document.addEventListener("keydown", this._onKey)
    this._observer = new MutationObserver(()=> {
      if(this.frameTarget && this.frameTarget.innerHTML.trim()===""){ this.close() }
    })
    this._observer.observe(this.frameTarget, { childList:true, subtree:true })
  }
  disconnect(){
    document.removeEventListener("turbo:frame-load", this._onFrameLoad)
    document.removeEventListener("keydown", this._onKey)
    this._observer?.disconnect()
  }
  open(){ this.overlayTarget.hidden=false; document.body.style.overflow="hidden" }
  close(){ this.frameTarget.innerHTML=""; this.overlayTarget.hidden=true; document.body.style.overflow="" }
  backdrop(e){ if(e.target===this.overlayTarget) this.close() }
}
