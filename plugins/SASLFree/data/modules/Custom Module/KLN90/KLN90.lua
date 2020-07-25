--size = { 2048, 2048 }

-- Creating common drefs for panels and engine

---------- KLN drefs ---------------

createGlobalPropertyi("kln90b/MD41/test", 0); -- MD41 test lamp mode
createGlobalPropertyi("kln90b/MD41/OBSreq", 0)
createGlobalPropertyi("kln90b/MD41/visible", 0) -- show MD41 popup window

createGlobalPropertyi("kln90b/KLN90/OBS", 1)
createGlobalPropertyi("kln90b/KLN90/APR", 0)
createGlobalPropertyi("kln90b/KLN90/MSG", 0)
createGlobalPropertyi("kln90b/KLN90/WPT", 0)
createGlobalPropertyi("kln90b/KLN90/Flash", 0)
createGlobalPropertyi("kln90b/KLN90/SCAN", 0) -- flag if right knob in SCAN mode
createGlobalPropertyi("kln90b/KLN90/visible", 0) -- show/hide main KLN90B popup panel
createGlobalPropertyi("kln90b/KLN90pop/visible", 0) -- show/hide KLN popup control panel

createGlobalPropertyi("kln90b/KLN90pop/x", 1)
createGlobalPropertyi("kln90b/KLN90pop/y", 1)

---------- Local defs ---------------

components  = {
	KLN90_engine {},
	KLN90_panels {},
}


