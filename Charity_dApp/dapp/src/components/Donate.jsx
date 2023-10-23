import React, { useState } from 'react';

const Donate = ({ onDonate }) => {
  const [donationAmount, setDonationAmount] = useState('');

  const handleDonate = () => {
    if (donationAmount !== '') {
      onDonate(Number(donationAmount)); // Donate işlevini çağırarak bağış yapma işlemi gerçekleştirilir.
      setDonationAmount(''); // Bağış yapıldıktan sonra input alanını temizle
    }
  };

  return (
    <div>
      <h2>Donate</h2>
      <label>
        Donation Amount (ETH):
        <input type="number" step="0.01" value={donationAmount} onChange={(e) => setDonationAmount(e.target.value)} />
      </label>
      <button onClick={handleDonate}>Donate</button>
    </div>
  );
};

export default Donate;
