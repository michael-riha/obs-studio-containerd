import React from 'react';

function AudioMixer() {
  return (
    <div className="p-4 border-t border-base-300">
      <div className="font-bold mb-2">Audio Mixer</div>
      <div className="flex flex-col gap-4">
        <div>
          <div className="flex justify-between">
            <span>Mic/Aux</span>
            <span>-20 dB</span>
          </div>
          <input type="range" min="0" max="100" className="range range-xs" />
        </div>
        <div>
          <div className="flex justify-between">
            <span>Desktop Audio</span>
            <span>-10 dB</span>
          </div>
          <input type="range" min="0" max="100" className="range range-xs" />
        </div>
      </div>
    </div>
  );
}

export default AudioMixer;