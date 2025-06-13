import React from 'react';

function Controls({ streaming, setStreaming, recording, setRecording }) {
  return (
    <div className="mt-4 flex justify-between">
      {/* Media stats */}
      <div className="stats shadow">
        <div className="stat">
          <div className="stat-title">FPS</div>
          <div className="stat-value text-sm">60.0</div>
        </div>
        <div className="stat">
          <div className="stat-title">CPU</div>
          <div className="stat-value text-sm">12%</div>
        </div>
        <div className="stat">
          <div className="stat-title">Dropped Frames</div>
          <div className="stat-value text-sm">0 (0%)</div>
        </div>
      </div>
      
      {/* Streaming/Recording buttons */}
      <div className="flex gap-4">
        <button 
          className={`btn ${streaming ? 'btn-error' : 'btn-primary'}`}
          onClick={() => setStreaming(!streaming)}
        >
          {streaming ? 'Stop Streaming' : 'Start Streaming'}
        </button>
        <button 
          className={`btn ${recording ? 'btn-error' : 'btn-secondary'}`}
          onClick={() => setRecording(!recording)}
        >
          {recording ? 'Stop Recording' : 'Start Recording'}
        </button>
        <button className="btn btn-accent">
          Studio Mode
        </button>
      </div>
    </div>
  );
}

export default Controls;