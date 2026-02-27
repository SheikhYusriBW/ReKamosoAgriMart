export default function ContractDetailPage({ params }: { params: { id: string } }) {
  return (
    <div>
      <h1>Contract Detail: {params.id}</h1>
    </div>
  );
}
