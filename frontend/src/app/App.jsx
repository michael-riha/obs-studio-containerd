import React, { useState } from 'react';
import Header from './components/Header';
import Preview from './components/Preview';
import Controls from './components/Controls';
import SceneList from './components/SceneList';
import SourceList from './components/SourceList';
import AudioMixer from './components/AudioMixer';

function App() {
  const [scenes, setScenes] = useState([
    { id: 1, name: 'Scene 1', active: true },
    { id: 2, name: 'Scene 2', active: false },
    { id: 3, name: 'Scene 3', active: false },
  ]);
  
  const [sources, setSources] = useState([
    { id: 1, name: 'Display Capture', type: 'display', visible: true },
    { id: 2, name: 'Mic/Aux', type: 'audio', visible: true },
    { id: 3, name: 'Browser Source', type: 'browser', visible: true },
  ]);
  
  const [streaming, setStreaming] = useState(false);
  const [recording, setRecording] = useState(false);
  
  return (
    <div className="drawer lg:drawer-open bg-base-300 h-screen">
      <input id="obs-drawer" type="checkbox" className="drawer-toggle" />
      
      {/* Main content */}
      <div className="drawer-content flex flex-col">
        <Header />
        
        {/* Main preview area */}
        <div className="flex-1 p-4">
          <Preview />
          <Controls 
            streaming={streaming} 
            setStreaming={setStreaming} 
            recording={recording} 
            setRecording={setRecording} 
          />
        </div>
      </div>
      
      {/* Sidebar/Drawer */}
      <div className="drawer-side">
        <label htmlFor="obs-drawer" className="drawer-overlay"></label>
        <div className="w-80 h-full bg-base-200 flex flex-col">
          {/* Scenes and Sources container */}
          <div className="p-4 flex-1">
            <div className="font-bold mb-2">Scenes</div>
            <SceneList scenes={scenes} setScenes={setScenes} />
            
            <div className="font-bold mb-2">Sources</div>
            <SourceList sources={sources} setSources={setSources} />
          </div>
          
          <AudioMixer />
        </div>
      </div>
    </div>
  );
}

export default App;