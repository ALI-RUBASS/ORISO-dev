import * as React from 'react';
import Lottie, { LottieRef } from 'lottie-react';
import matchingAnimationData from '../../resources/animations/Matching-Animation.json';
import './consultantMatchingAnimation.styles.scss';

export const ConsultantMatchingAnimation: React.FC = () => {
	const lottieRef: LottieRef = React.useRef(null);

	React.useEffect(() => {
		if (lottieRef.current) {
			// Set speed to 0.5 (2x slower)
			lottieRef.current.setSpeed(0.5);
		}
	}, []);

	return (
		<div className="consultantMatchingAnimation">
			<Lottie
				lottieRef={lottieRef}
				animationData={matchingAnimationData}
				loop={true}
				autoplay={true}
				style={{
					width: '100%',
					maxWidth: '600px',
					margin: '0 auto'
				}}
			/>
		</div>
	);
};


