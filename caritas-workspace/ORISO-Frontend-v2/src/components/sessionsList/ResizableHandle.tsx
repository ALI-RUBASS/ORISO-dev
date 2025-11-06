import * as React from 'react';
import { useState, useEffect, useCallback } from 'react';

interface ResizableHandleProps {
	onResize: (width: number) => void;
	minWidth?: number;
	maxWidth?: number;
}

export const ResizableHandle: React.FC<ResizableHandleProps> = ({
	onResize,
	minWidth = 80,
	maxWidth = 600
}) => {
	const [isDragging, setIsDragging] = useState(false);

	const handleMouseDown = useCallback((e: React.MouseEvent) => {
		e.preventDefault();
		setIsDragging(true);
	}, []);

	const handleMouseMove = useCallback(
		(e: MouseEvent) => {
			if (!isDragging) return;

			const newWidth = Math.min(
				Math.max(e.clientX, minWidth),
				maxWidth
			);
			
			onResize(newWidth);
		},
		[isDragging, onResize, minWidth, maxWidth]
	);

	const handleMouseUp = useCallback(() => {
		setIsDragging(false);
	}, []);

	useEffect(() => {
		if (isDragging) {
			document.addEventListener('mousemove', handleMouseMove);
			document.addEventListener('mouseup', handleMouseUp);
			document.body.style.cursor = 'col-resize';
			document.body.style.userSelect = 'none';

			return () => {
				document.removeEventListener('mousemove', handleMouseMove);
				document.removeEventListener('mouseup', handleMouseUp);
				document.body.style.cursor = '';
				document.body.style.userSelect = '';
			};
		}
	}, [isDragging, handleMouseMove, handleMouseUp]);

	return (
		<div
			className="sessionsList__resizeHandle"
			onMouseDown={handleMouseDown}
			style={{
				position: 'absolute',
				right: '-2px',
				top: 0,
				bottom: 0,
				width: '4px',
				cursor: 'col-resize',
				backgroundColor: isDragging ? '#0086E6' : 'rgba(0, 134, 230, 0.1)',
				transition: isDragging ? 'none' : 'background-color 0.2s',
				zIndex: 10
			}}
			onMouseEnter={(e) => {
				e.currentTarget.style.backgroundColor = '#0086E6';
			}}
			onMouseLeave={(e) => {
				if (!isDragging) {
					e.currentTarget.style.backgroundColor = 'rgba(0, 134, 230, 0.1)';
				}
			}}
		/>
	);
};

