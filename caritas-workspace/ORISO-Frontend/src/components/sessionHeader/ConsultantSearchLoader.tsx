import * as React from 'react';
import './consultantSearchLoader.styles.scss';

interface ConsultantSearchLoaderProps {
	size?: string;
}

export const ConsultantSearchLoader: React.FC<ConsultantSearchLoaderProps> = ({
	size = '40px'
}) => {
	return (
		<div 
			className="consultantSearchLoader" 
			style={{ 
				width: size, 
				height: size
			}}
		>
			<div className="consultantSearchLoader__circle">
				<div className="consultantSearchLoader__loader">
					<div className="consultantSearchLoader__magnetism" />
				</div>
			</div>
		</div>
	);
};

