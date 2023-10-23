import React, { useState } from 'react';

const Vote = ({ onVote }) => {
  const [voteNumber, setVoteNumber] = useState('');
  
  const handleVote = () => {
    if (voteNumber !== '') {
      onVote(Number(voteNumber)); // Vote işlevini çağırarak oy verme işlemi gerçekleştirilir.
      setVoteNumber(''); // Oy verildikten sonra input alanını temizle
    }
  };

  return (
    <div>
      <h2>Vote</h2>
      <label>
        Vote Number:
        <input type="number" value={voteNumber} onChange={(e) => setVoteNumber(e.target.value)} />
      </label>
      <button onClick={handleVote}>Vote</button>
    </div>
  );
};

export default Vote;
